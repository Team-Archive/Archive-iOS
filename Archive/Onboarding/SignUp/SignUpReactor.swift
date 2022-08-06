//
//  SignUpReactor.swift
//  Archive
//
//  Created by TTOzzi on 2021/10/09.
//

import ReactorKit
import RxSwift
import RxRelay
import RxFlow
import SwiftyJSON
import Moya

final class SignUpReactor: Reactor, Stepper {
    
    enum Action {
        case checkAll
        case agreeTerms
        case viewTerms
        case agreePersonalInformationPolicy
        case viewPersonalInformationPolicy
        case goToEmailInput
        
        case registOAuthLogin(OAuthSignInType)
        
        case emailInput(text: String)
        case checkEmailDuplicate
        case goToPasswordInput
        
        case passwordInput(text: String)
        case passwordCofirmInput(text: String)
        case completeSignUp
        
        case startArchive
    }
    
    enum Mutation {
        case setTermsAgreement(Bool)
        case setPersonalInformationPolicyAgreement(Bool)
        
        case setEmail(String)
        case setEmailValidation(Bool)
        case setEmailDuplicate(Bool)
        case resetEmailValidation
        
        case setPassword(String)
        case setEnglishCombination(Bool)
        case setNumberCombination(Bool)
        case setRangeValidation(Bool)
        case setPasswordCofirmationInput(String)
        case setIsLoading(Bool)
        case empty
    }
    
    struct State {
        var isCheckAll: Bool {
            return isAgreeTerms && isAgreePersonalInformationPolicy
        }
        var isAgreeTerms: Bool = false
        var isAgreePersonalInformationPolicy: Bool = false
        
        var email: String = ""
        var isValidEmail: Bool = false
        var isDuplicateEmail: Bool = true
        var isCompleteEmailInput: Bool {
            return isValidEmail && (isDuplicateEmail == false)
        }
        var emailValidationText: String = ""
        
        var password: String = ""
        var isContainsEnglish: Bool = false
        var isContainsNumber: Bool = false
        var isWithinRange: Bool = false
        var passwordConfirmationInput: String = ""
        var isSamePasswordInput: Bool {
            if password == "" { return false }
            return password == passwordConfirmationInput
        }
        var isValidPassword: Bool {
            return isContainsEnglish && isContainsNumber && isWithinRange && isSamePasswordInput
        }
        var isLoading: Bool = false
    }
    
    let initialState = State()
    let steps = PublishRelay<Step>()
    private let validator: SignUpValidator
    var error: PublishSubject<String>
    var oAuthAccessToken: String = ""
    var oAuthLoginType: OAuthSignInType = .kakao
    private let emailLogInUsecase: EMailLogInUsecase
    
    init(validator: SignUpValidator, emailLogInRepository: EMailLogInRepository) {
        self.validator = validator
        self.error = .init()
        self.emailLogInUsecase = EMailLogInUsecase(repository: emailLogInRepository)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .checkAll:
            let isSelected = !currentState.isCheckAll
            return .from([.setTermsAgreement(isSelected),
                          .setPersonalInformationPolicyAgreement(isSelected)])
            
        case .agreeTerms:
            let isSelected = !currentState.isAgreeTerms
            return .just(.setTermsAgreement(isSelected))
            
        case .viewTerms:
            guard let url = URL(string: "https://wise-icicle-d10.notion.site/8ad4c5884b814ff6a6330f1a6143c1e6") else { return .empty()}
            self.steps.accept(ArchiveStep.openUrlIsRequired(url: url, title: "이용약관"))
            return .empty()
        case .agreePersonalInformationPolicy:
            let isSelected = !currentState.isAgreePersonalInformationPolicy
            return .just(.setPersonalInformationPolicyAgreement(isSelected))
        case .viewPersonalInformationPolicy:
            guard let url = URL(string: "https://wise-icicle-d10.notion.site/13ff403ad4e2402ca657fb20be31e4ae") else { return .empty()}
            self.steps.accept(ArchiveStep.openUrlIsRequired(url: url, title: "개인정보 처리방침"))
            return .empty()
        case .goToEmailInput:
            steps.accept(ArchiveStep.emailInputRequired)
            return .empty()
        case let .emailInput(email):
            let isValid = validator.isValidEmail(email)
            return .from([.resetEmailValidation,
                          .setEmail(email),
                          .setEmailValidation(isValid)])
            
        case .checkEmailDuplicate:
            return Observable.concat([
                Observable.just(.setIsLoading(true)),
                checkIsDuplicatedEmail(eMail: self.currentState.email)
                    .map { [weak self] result in
                        switch result {
                        case .success(let isDup):
                            return .setEmailDuplicate(isDup)
                        case .failure(let err):
                            self?.error.onNext("error\(err.localizedDescription)")
                        }
                        return .setIsLoading(false)
                    },
                Observable.just(.setIsLoading(false))
            ])
        case .goToPasswordInput:
            steps.accept(ArchiveStep.passwordInputRequired)
            return .empty()
            
        case let .passwordInput(text):
            let isContainsEnglish = validator.isContainsEnglish(text)
            let isContainsNumber = validator.isContainsNumber(text)
            let isWithinRage = validator.isWithinRange(text, range: (8...20))
            return .from([.setPassword(text),
                          .setEnglishCombination(isContainsEnglish),
                          .setNumberCombination(isContainsNumber),
                          .setRangeValidation(isWithinRage)])
            
        case let .passwordCofirmInput(text):
            return .just(.setPasswordCofirmationInput(text))
            
        case .completeSignUp:
            return Observable.concat([
                Observable.just(.setIsLoading(true)),
                registEmail(eMail: self.currentState.email, password: self.currentState.password)
                    .map { [weak self] result in
                        switch result {
                        case .success(_):
                            self?.steps.accept(ArchiveStep.userIsSignedUp)
                        case .failure(let err):
                            self?.error.onNext(ServerErrorUtil.getErrMsg(err))
                        }
                        return .setIsLoading(false)
                    }
            ])
        case .startArchive:
            return Observable.concat([
                Observable.just(.setIsLoading(true)),
                eMailLogIn(email: self.currentState.email, password: self.currentState.password)
                    .map { [weak self] result in
                        switch result {
                        case .success(let logInSuccessType):
                            switch logInSuccessType {
                            case .logInSuccess(let token):
                                LogInManager.shared.logIn(token: token, type: .eMail)
                                self?.steps.accept(ArchiveStep.userIsSignedIn)
                            case .isTempPW:
                                self?.steps.accept(ArchiveStep.changePasswordFromFindPassword)
                            }
                        case .failure(let err):
                            self?.error.onNext(err.getMessage())
                        }
                        return .empty
                    },
                Observable.just(.setIsLoading(false))
            ])
        case .registOAuthLogin(let type):
            return Observable.concat([
                Observable.just(.setIsLoading(true)),
                self.registWithOAuth(accessToken: self.oAuthAccessToken, type: type).map { [weak self] result in
                    switch result {
                    case .success(_):
                        self?.steps.accept(ArchiveStep.userIsSignedIn)
                    case .failure(let err):
                        self?.error.onNext(err.getMessage())
                    }
                    return .empty
                },
                Observable.just(.setIsLoading(false))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setTermsAgreement(isSelected):
            newState.isAgreeTerms = isSelected
            
        case let .setPersonalInformationPolicyAgreement(isSelected):
            newState.isAgreePersonalInformationPolicy = isSelected
            
        case let .setEmail(email):
            newState.email = email
            
        case let .setEmailValidation(isValid):
            newState.isValidEmail = isValid
            newState.emailValidationText = ""
            
        case let .setEmailDuplicate(isDuplicate):
            newState.isDuplicateEmail = isDuplicate
            newState.emailValidationText = isDuplicate ? "중복된 이메일입니다" : "중복되지 않은 이메일입니다"
            
        case .resetEmailValidation:
            newState.isValidEmail = false
            newState.isDuplicateEmail = true
            
        case let .setPassword(password):
            newState.password = password
            
        case let .setEnglishCombination(isContainsEnglish):
            newState.isContainsEnglish = isContainsEnglish
            
        case let.setNumberCombination(isContainsNumber):
            newState.isContainsNumber = isContainsNumber
            
        case let .setRangeValidation(isWithinRange):
            newState.isWithinRange = isWithinRange
            
        case let .setPasswordCofirmationInput(password):
            newState.passwordConfirmationInput = password
        case .setIsLoading(let isLoading):
            newState.isLoading = isLoading
            
        case .empty:
            break
        }
        
        return newState
    }
    
    private func registEmail(eMail: String, password: String) -> Observable<Result<Void, Error>> {
        let provider = ArchiveProvider.shared.provider
        let param = RequestEmailParam(email: eMail, password: password)
        return provider.rx.request(.registEmail(param), callbackQueue: DispatchQueue.global())
            .asObservable()
            .map { result in
                return .success(Void())
            }
            .catch { err in
                .just(.failure(err))
            }
    }
    
    private func checkIsDuplicatedEmail(eMail: String) -> Observable<Result<Bool, Error>> {
        let provider = ArchiveProvider.shared.provider
        return provider.rx.request(.isDuplicatedEmail(eMail), callbackQueue: DispatchQueue.global())
            .asObservable()
            .map { response in
                if let result: JSON = try? JSON.init(data: response.data) {
                    let isDup: Bool = result["duplicatedEmail"].boolValue
                    if isDup {
                        return .success(true)
                    } else {
                        return .success(false)
                    }
                } else {
                    return .success(true)
                }
            }
            .catch { err in
                .just(.failure(err))
            }
    }
    
    // TODO: Usecase생성 후 이동하기
    private func registWithOAuth(accessToken: String, type: OAuthSignInType) -> Observable<Result<Void, ArchiveError>> {
        let provider = ArchiveProvider.shared.provider
        return provider.rx.request(.logInWithOAuth(logInType: type, token: accessToken), callbackQueue: DispatchQueue.global())
            .asObservable()
            .map { result in
                if result.statusCode == 200 {
                    guard let header = result.response?.headers else { return .failure(.init(.responseHeaderIsNull))}
                    guard let loginToken = header["Authorization"] else { return .failure(.init(.responseHeaderIsNull))}
                    // TODO: DIP를 이용해 바꿀것
                    // TODO: kakao Login 모듈과 중복된 코드
                    var loginType: LoginType = .eMail
                    switch type {
                    case .apple:
                        loginType = .apple
                    case .kakao:
                        loginType = .kakao
                    }
                    LogInManager.shared.logIn(token: loginToken, type: loginType)
                    //
                    return .success(())
                } else {
                    return .failure(.init(from: .server, code: result.statusCode, message: "서버오류"))
                }
            }
            .catch { err in
                return .just(.failure(.init(from: .server, code: err.responseCode, message: err.archiveErrMsg)))
            }
    }
    
    private func eMailLogIn(email: String, password: String) -> Observable<Result<EMailLogInSuccessType, ArchiveError>> {
        return self.emailLogInUsecase.loginEmail(eMail: email, password: password)
    }
}

struct RequestEmailParam: Encodable {
    var email: String
    var password: String
}

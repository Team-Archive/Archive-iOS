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
        case completeAgreePolicy
        
        case emailInput(text: String)
        case checkEmailDuplicate
        case goToPasswordInput
        
        case checkIsDuplicatedNickname(String)
        case nicknameTextFieldIsChanged
        case nicknameSetIsComplete(nickname: String)
        
        case passwordInput(text: String)
        case passwordCofirmInput(text: String)
        case passwordSetComplete
        
        case startArchive
    }
    
    enum Mutation {
        case setTermsAgreement(Bool)
        case setPersonalInformationPolicyAgreement(Bool)
        
        case setEmail(String)
        case setEmailValidation(Bool)
        case setEmailDuplicate(Bool)
        case resetEmailValidation
        
        case setIsDuplicatedNickname(Bool)
        case setIsCheckedSuccessNicknameDuplication(Bool)
        
        case setPassword(String)
        case setEnglishCombination(Bool)
        case setNumberCombination(Bool)
        case setRangeValidation(Bool)
        case setPasswordCofirmationInput(String)
        case setIsLoading(Bool)
        
        case setNickname(String)
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
        
        var isSuccessCheckedDuplicatedNickname: Bool = false
        var isDuplicatedNickname: Pulse<Bool> = .init(wrappedValue: false)
        var nickname: String = ""
    }
    
    let initialState = State()
    let steps = PublishRelay<Step>()
    private let validator: SignUpValidator
    var error: PublishSubject<String>
    var oAuthAccessToken: String = ""
    var loginType: LoginType = .eMail
    private let emailLogInUsecase: EMailLogInUsecase
    private let nicknameDuplicationUsecase: NickNameDuplicationUsecase
    private let signUpEmailUsecase: SignUpEmailUsecase
    private let signUpOAuthUsecase: SignUpOAuthUsecase
    
    init(validator: SignUpValidator,
         emailLogInRepository: EMailLogInRepository,
         nicknameDuplicationRepository: NickNameDuplicationRepository,
         signUpEmailRepository: SignUpEmailRepository,
         signUpOAuthRepository: SignUpOAuthRepository
    ) {
        self.validator = validator
        self.error = .init()
        self.emailLogInUsecase = EMailLogInUsecase(repository: emailLogInRepository)
        self.nicknameDuplicationUsecase = NickNameDuplicationUsecase(repository: nicknameDuplicationRepository)
        self.signUpEmailUsecase = SignUpEmailUsecase(repository: signUpEmailRepository)
        self.signUpOAuthUsecase = SignUpOAuthUsecase(repository: signUpOAuthRepository)
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
            guard let url = URL(string: CommonDefine.termsUrl) else { return .empty()}
            self.steps.accept(ArchiveStep.openUrlIsRequired(url: url, title: "이용약관"))
            return .empty()
        case .agreePersonalInformationPolicy:
            let isSelected = !currentState.isAgreePersonalInformationPolicy
            return .just(.setPersonalInformationPolicyAgreement(isSelected))
        case .viewPersonalInformationPolicy:
            guard let url = URL(string: CommonDefine.privacyUrl) else { return .empty()}
            self.steps.accept(ArchiveStep.openUrlIsRequired(url: url, title: "개인정보 처리방침"))
            return .empty()
        case .completeAgreePolicy:
            switch self.loginType {
            case .eMail:
                steps.accept(ArchiveStep.emailInputRequired)
            case .kakao, .apple:
                steps.accept(ArchiveStep.nicknameSignupIsRequired)
            }
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
                            self?.error.onNext(err.archiveErrMsg)
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
        case .startArchive:
            self.steps.accept(ArchiveStep.userIsSignedIn(isTempPw: false))
            return .empty()
        case .checkIsDuplicatedNickname(let nickname):
            return Observable.concat([
                Observable.just(.setIsLoading(true)),
                self.checkIsDuplicatedNickname(nickname)
                    .map { result -> Result<Bool, ArchiveError> in
                        return result
                    }.flatMap { [weak self] result -> Observable<Mutation> in
                        switch result {
                        case .success(let isDuplicated):
                            if isDuplicated {
                                return .from([
                                    .setIsDuplicatedNickname(true),
                                    .setIsCheckedSuccessNicknameDuplication(false)
                                ])
                            } else {
                                return .from([
                                    .setIsDuplicatedNickname(true),
                                    .setIsCheckedSuccessNicknameDuplication(true)
                                ])
                            }
                        case .failure(let err):
                            self?.error.onNext(err.getMessage())
                            return .empty()
                        }
                    },
                Observable.just(.setIsLoading(false))
            ])
        case .passwordSetComplete:
            steps.accept(ArchiveStep.nicknameSignupIsRequired)
            return .empty()
        case .nicknameTextFieldIsChanged:
            return .just(.setIsCheckedSuccessNicknameDuplication(false))
        case .nicknameSetIsComplete(let nickname):
            switch self.loginType {
            case .eMail:
                return Observable.concat([
                    Observable.just(.setIsLoading(true)),
                    registEmail(eMail: self.currentState.email, nickname: nickname, password: self.currentState.password)
                        .map { [weak self] result in
                            switch result {
                            case .success(let token):
                                LogInManager.shared.logIn(token: token, type: .eMail)
                                LogInManager.shared.refreshProfile()
                                self?.steps.accept(ArchiveStep.userIsSignedUp)
                            case .failure(let err):
                                self?.error.onNext(err.archiveErrMsg)
                            }
                            return .empty
                        },
                    Observable.just(.setIsLoading(false))
                ])
            case .kakao, .apple:
                return Observable.concat([
                    Observable.just(.setIsLoading(true)),
                    self.registWithOAuth(accessToken: self.oAuthAccessToken, type: self.loginType, nickname: nickname).map { [weak self] result in
                        switch result {
                        case .success(_):
                            self?.steps.accept(ArchiveStep.userIsSignedIn(isTempPw: false))
                            LogInManager.shared.refreshProfile()
                        case .failure(let err):
                            self?.error.onNext(err.getMessage())
                        }
                        return .empty
                    },
                    Observable.just(.setIsLoading(false))
                ])
            }
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
            
        case .setIsCheckedSuccessNicknameDuplication(let isChecked):
            newState.isSuccessCheckedDuplicatedNickname = isChecked
        case .setIsDuplicatedNickname(let isDuplicated):
            newState.isDuplicatedNickname.value = isDuplicated
        case .empty:
            break
        case .setNickname(let nickname):
            newState.nickname = nickname
        }
        
        return newState
    }
    
    private func registEmail(eMail: String, nickname: String, password: String) -> Observable<Result<String, ArchiveError>> {
        return self.signUpEmailUsecase.registEmail(eMail: eMail, nickname: nickname, password: password)
    }
    
    private func checkIsDuplicatedEmail(eMail: String) -> Observable<Result<Bool, ArchiveError>> {
        return self.signUpEmailUsecase.checkIsDuplicatedEmail(eMail: eMail)
    }
    
    private func registWithOAuth(accessToken: String, type: LoginType, nickname: String) -> Observable<Result<Void, ArchiveError>> {
        switch type {
        case .eMail:
            return .just(.failure(.init(.invalidLoginType)))
        case .apple, .kakao:
            return self.signUpOAuthUsecase.registOAuth(nickname: nickname, provider: type, providerAccessToken: accessToken).flatMap { result -> Observable<Result<Void, ArchiveError>> in
                switch result {
                case .success(let token):
                    LogInManager.shared.logIn(token: token, type: .apple)
                    return .just(.success(()))
                case .failure(let err):
                    return .just(.failure(err))
                }
            }
        }
    }
    
    
    private func eMailLogIn(email: String, password: String) -> Observable<Result<EMailLogInSuccessData, ArchiveError>> {
        return self.emailLogInUsecase.loginEmail(eMail: email, password: password)
    }
    
    private func checkIsDuplicatedNickname(_ nickname: String) -> Observable<Result<Bool, ArchiveError>> {
        return self.nicknameDuplicationUsecase.isDuplicatedNickName(nickname)
    }
}

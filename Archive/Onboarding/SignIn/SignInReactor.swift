//
//  SignInReactor.swift
//  Archive
//
//  Created by TTOzzi on 2021/10/02.
//

import ReactorKit
import RxSwift
import RxRelay
import RxFlow
import Alamofire

final class SignInReactor: Reactor, Stepper {
    
    enum Action {
        case idInput(text: String)
        case passwordInput(text: String)
        case moveToEmailSignIn
        case signIn
        case signUp
        case signInWithApple
        case signInWithKakao
        case isExistIdCheckWithKakao(accessToken: String)
        case realLoginWithKakao(accessToken: String)
        case moveToFindPassword
        case sendTempPassword
        case changepasswordInput(text: String)
        case passwordCofirmInput(text: String)
        case tempPasswordInput(text: String)
        case changePassword
    }
    
    enum Mutation {
        case setID(String)
        case setPassword(String)
        case setIsVaildEmail(Bool)
        case setValidation(Bool)
        case setIsLoading(Bool)
        case empty
        case setChangePassword(String)
        case setEnglishCombination(Bool)
        case setNumberCombination(Bool)
        case setRangeValidation(Bool)
        case setPasswordCofirmationInput(String)
        case setTempPasswordInput(String)
    }
    
    struct State {
        var id: String = ""
        var password: String = ""
        var isValidEmail: Bool = false
        var isEnableSignIn: Bool = false
        var isLoading: Bool = false
    
        var tempPassword: String = ""
        var changePassword: String = ""
        var isContainsEnglish: Bool = false
        var isContainsNumber: Bool = false
        var isWithinRange: Bool = false
        var passwordConfirmationInput: String = ""
        var isSamePasswordInput: Bool {
            if changePassword == "" { return false }
            return changePassword == passwordConfirmationInput
        }
        var isNotNullTempPassword: Bool {
            if tempPassword == "" {
                return false
            } else {
                return true
            }
        }
        var isValidPassword: Bool {
            return isContainsEnglish && isContainsNumber && isWithinRange && isSamePasswordInput && isNotNullTempPassword
        }
    }
    
    let initialState = State()
    let steps = PublishRelay<Step>()
    private let validator: Validator
    var error: PublishSubject<String>
    var toastMessage: PublishSubject<String>
    var popToRootView: PublishSubject<Void>
    private let oAuthUsecase: LoginOAuthUsecase
    private let findPasswordUsecase: FindPasswordUsecase
    
    init(validator: Validator, loginOAuthRepository: LoginOAuthRepository, findPasswordRepository: FindPasswordRepository) {
        self.validator = validator
        self.error = .init()
        self.toastMessage = .init()
        self.popToRootView = .init()
        self.oAuthUsecase = LoginOAuthUsecase(repository: loginOAuthRepository)
        self.findPasswordUsecase = FindPasswordUsecase(repository: findPasswordRepository)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .idInput(id):
            let isValid = validator.isValidEmail(id)
            return .from([.setID(id),
                          .setIsVaildEmail(isValid)])
            
        case .moveToEmailSignIn:
            steps.accept(ArchiveStep.eMailSignIn(reactor: self))
            return .empty()
            
        case let .passwordInput(password):
            let isValid = validator.isEnableSignIn(id: currentState.id, password: password)
            return .from([.setPassword(password),
                          .setValidation(isValid)])
            
        case .signIn:
            return Observable.concat([
                Observable.just(.setIsLoading(true)),
                LoginModule.loginEmail(eMail: self.currentState.id, password: self.currentState.password).map { [weak self] result in
                    switch result {
                    case .success(let response):
                        guard let token: String = response["Authorization"] else {
                            self?.error.onNext("[오류] 토큰이 존재하지 않습니다.")
                            return .setIsLoading(false)
                        }
                        LogInManager.shared.logIn(token: token, type: .eMail)
                        self?.steps.accept(ArchiveStep.userIsSignedIn)
                    case .failure(let err):
                        print("err: \(err)")
                        self?.error.onNext("로그인 정보가 정확하지 않습니다.")
                    }
                    return .setIsLoading(false)
                }
            ])
        case .signUp:
            steps.accept(ArchiveStep.termsAgreementIsRequired)
            return .empty()
        case .signInWithApple:
            getAppleLoginToken { [weak self] result in
                print("Apple OAuth Token: \(result)") // TODO: 해당 토큰으로 서버에 로그인 혹은 회원가입 처리
            }
            return .empty()
        case .signInWithKakao:
            getKakaoLoginToken { [weak self] result in
                switch result {
                case .success(let accessToken):
                    self?.action.onNext(.isExistIdCheckWithKakao(accessToken: accessToken))
                case .failure(let err):
                    self?.error.onNext(err.getMessage())
                }
            }
            return .empty()
        case .isExistIdCheckWithKakao(let accessToken):
            return Observable.concat([
                Observable.just(.setIsLoading(true)),
                isExistEmailWithKakao(accessToken: accessToken).map { [weak self] isExist in
                    if isExist {
                        self?.action.onNext(.realLoginWithKakao(accessToken: accessToken))
                    } else {
                        self?.steps.accept(ArchiveStep.termsAgreeForOAuthRegist(accessToken: accessToken))
                    }
                    return .empty
                },
                Observable.just(.setIsLoading(false))
            ])
        case .realLoginWithKakao(accessToken: let accessToken):
            return Observable.concat([
                Observable.just(.setIsLoading(true)),
                realLoginWithKakao(accessToken: accessToken).map { [weak self] result in
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
        case .moveToFindPassword:
            steps.accept(ArchiveStep.findPassword)
            return .empty()
        case .sendTempPassword:
            return Observable.concat([
                Observable.just(.setIsLoading(true)),
                sendTempPassword(email: self.currentState.id).map { [weak self] isSuccessSendTempPasswordResult in
                    switch isSuccessSendTempPasswordResult {
                    case .success(let isSuccess):
                        if isSuccess {
                            self?.toastMessage.onNext("임시 비밀번호가 발송되었습니다.")
                            self?.steps.accept(ArchiveStep.changePasswordFromFindPassword)
                        } else {
                            self?.toastMessage.onNext("가입하지 않은 이메일입니다. 회원가입으로 이동해주세요.")
                        }
                    case .failure(let err):
                        self?.error.onNext(err.getMessage())
                    }
                    return .empty
                },
                Observable.just(.setIsLoading(false))
            ])
        case let .changepasswordInput(text):
            let isContainsEnglish = validator.isContainsEnglish(text)
            let isContainsNumber = validator.isContainsNumber(text)
            let isWithinRage = validator.isWithinRange(text, range: (8...20))
            return .from([.setChangePassword(text),
                          .setEnglishCombination(isContainsEnglish),
                          .setNumberCombination(isContainsNumber),
                          .setRangeValidation(isWithinRage)])
            
        case let .passwordCofirmInput(text):
            return .just(.setPasswordCofirmationInput(text))
        case .tempPasswordInput(text: let text):
            return .just(.setTempPasswordInput(text))
        case .changePassword:
            return Observable.concat([
                Observable.just(.setIsLoading(true)),
                changePassword(email: self.currentState.id,
                               tempPassword: self.currentState.tempPassword,
                               newPassword: self.currentState.changePassword)
                .map { [weak self] changePasswordResult in
                    switch changePasswordResult {
                    case .success(()):
                        self?.toastMessage.onNext("비밀번호 변경 완료")
                        self?.popToRootView.onNext(())
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
        case let .setID(id):
            newState.id = id
        case let .setPassword(password):
            newState.password = password
        case .setIsVaildEmail(let isValidEmail):
            newState.isValidEmail = isValidEmail
        case let.setValidation(isEnableSignIn):
            newState.isEnableSignIn = isEnableSignIn
        case let .setIsLoading(isLoading):
            newState.isLoading = isLoading
        case .empty:
            break
        case let .setChangePassword(password):
            newState.changePassword = password
        case let .setEnglishCombination(isContainsEnglish):
            newState.isContainsEnglish = isContainsEnglish
        case let.setNumberCombination(isContainsNumber):
            newState.isContainsNumber = isContainsNumber
        case let .setRangeValidation(isWithinRange):
            newState.isWithinRange = isWithinRange
        case let .setPasswordCofirmationInput(password):
            newState.passwordConfirmationInput = password
        case .setTempPasswordInput(let password):
            newState.tempPassword = password
        }
        return newState
    }
    
    private func getAppleLoginToken(completion: @escaping (Result<String, ArchiveError>) -> Void) {
        self.oAuthUsecase.getToken(type: .apple, completion: completion)
    }
    
    private func getKakaoLoginToken(completion: @escaping (Result<String, ArchiveError>) -> Void) {
        self.oAuthUsecase.getToken(type: .kakao, completion: completion)
    }
    
    private func isExistEmailWithKakao(accessToken: String) -> Observable<Bool> {
        self.oAuthUsecase.isExistEmailWithKakao(accessToken: accessToken)
    }
    
    private func realLoginWithKakao(accessToken: String) -> Observable<Result<Void, ArchiveError>> {
        return self.oAuthUsecase.loginWithKakao(accessToken: accessToken).map { [weak self] result in
            switch result {
            case .success(let loginToken):
                LogInManager.shared.logIn(token: loginToken, type: .kakao)
                return .success(())
            case .failure(let err):
                return .failure(err)
            }
        }
    }
    
    private func sendTempPassword(email: String) -> Observable<Result<Bool, ArchiveError>> {
        return self.findPasswordUsecase.sendTempPassword(email: email)
    }
    
    private func changePassword(email: String, tempPassword: String, newPassword: String) -> Observable<Result<Void, ArchiveError>> {
        return self.findPasswordUsecase.changePassword(eMail: email, tempPassword: tempPassword, newPassword: newPassword)
    }
    
    
}

struct LoginEmailParam: Encodable {
    var email: String
    var password: String
}

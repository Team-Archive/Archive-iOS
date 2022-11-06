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
        case isExistIdCheckWithApple(accessToken: String)
        case realLoginWithKakao(accessToken: String)
        case realLoginWithApple(accessToken: String)
        case moveToFindPassword
        case sendTempPassword
        case changepasswordInput(text: String)
        case passwordCofirmInput(text: String)
        case tempPasswordInput(text: String)
        case changePassword
        case debugTouchAction
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
    var showDebugPasswordInputView: PublishSubject<Void> = .init()
    private let oAuthUsecase: LoginOAuthUsecase
    private let findPasswordUsecase: FindPasswordUsecase
    private let emailLogInUsecase: EMailLogInUsecase
    private var debugTouchCnt: Int = 0
    
    init(validator: Validator, loginOAuthRepository: LoginOAuthRepository, findPasswordRepository: FindPasswordRepository, emailLogInRepository: EMailLogInRepository) {
        self.validator = validator
        self.error = .init()
        self.toastMessage = .init()
        self.popToRootView = .init()
        self.oAuthUsecase = LoginOAuthUsecase(repository: loginOAuthRepository)
        self.findPasswordUsecase = FindPasswordUsecase(repository: findPasswordRepository)
        self.emailLogInUsecase = EMailLogInUsecase(repository: emailLogInRepository)
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
                eMailLogIn(email: self.currentState.id, password: self.currentState.password)
                    .map { [weak self] result in
                        switch result {
                        case .success(let logInSuccessType):
                            switch logInSuccessType {
                            case .logInSuccess(let token):
                                LogInManager.shared.logIn(token: token, type: .eMail)
                                LogInManager.shared.refreshProfile()
                                self?.steps.accept(ArchiveStep.userIsSignedIn)
                            case .isTempPW:
                                self?.toastMessage.onNext("임시 비밀번호를 변경해주세요.")
                                self?.steps.accept(ArchiveStep.changePasswordFromFindPassword)
                            }
                        case .failure(let err):
                            self?.error.onNext(err.getMessage())
                        }
                        return .empty
                    },
                Observable.just(.setIsLoading(false))
            ])
        case .signUp:
            steps.accept(ArchiveStep.termsAgreementIsRequired)
            return .empty()
        case .signInWithApple:
            getAppleLoginToken { [weak self] result in
                switch result {
                case .success(let accessToken):
                    self?.action.onNext(.isExistIdCheckWithApple(accessToken: accessToken))
                case .failure(let err):
                    self?.error.onNext(err.getMessage())
                }
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
                        self?.steps.accept(ArchiveStep.termsAgreeForOAuthRegist(accessToken: accessToken, loginType: .kakao))
                    }
                    return .empty
                },
                Observable.just(.setIsLoading(false))
            ])
        case .isExistIdCheckWithApple(let accessToken):
            return Observable.concat([
                Observable.just(.setIsLoading(true)),
                isExistEmailWithApple(accessToken: accessToken).map { [weak self] isExist in
                    if isExist {
                        self?.action.onNext(.realLoginWithApple(accessToken: accessToken))
                    } else {
                        self?.steps.accept(ArchiveStep.termsAgreeForOAuthRegist(accessToken: accessToken, loginType: OAuthSignInType.apple))
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
                        LogInManager.shared.refreshProfile()
                        self?.steps.accept(ArchiveStep.userIsSignedIn)
                    case .failure(let err):
                        self?.error.onNext(err.getMessage())
                    }
                    return .empty
                },
                Observable.just(.setIsLoading(false))
            ])
        case .realLoginWithApple(accessToken: let accessToken):
            return Observable.concat([
                Observable.just(.setIsLoading(true)),
                realLoginWithApple(accessToken: accessToken).map { [weak self] result in
                    switch result {
                    case .success(_):
                        LogInManager.shared.refreshProfile()
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
                        self?.toastMessage.onNext("비밀번호 변경 완료.\n변경된 비밀번호로 로그인해주세요.")
                        self?.popToRootView.onNext(())
                    case .failure(let err):
                        self?.error.onNext(err.getMessage())
                    }
                    return .empty
                },
                Observable.just(.setIsLoading(false))
            ])
        case .debugTouchAction:
            debugTouch()
            return .empty()
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
        return self.oAuthUsecase.isExistEmailWithKakao(accessToken: accessToken)
    }
    
    private func isExistEmailWithApple(accessToken: String) -> Observable<Bool> {
        return self.oAuthUsecase.isExistEmailWithApple(accessToken: accessToken)
    }
    
    private func realLoginWithKakao(accessToken: String) -> Observable<Result<Void, ArchiveError>> {
        return self.oAuthUsecase.loginWithKakao(accessToken: accessToken).map { result in
            switch result {
            case .success(let loginToken):
                LogInManager.shared.logIn(token: loginToken, type: .kakao)
                return .success(())
            case .failure(let err):
                return .failure(err)
            }
        }
    }
    
    private func realLoginWithApple(accessToken: String) -> Observable<Result<Void, ArchiveError>> {
        return self.oAuthUsecase.loginWithApple(accessToken: accessToken).map { result in
            switch result {
            case .success(let loginToken):
                LogInManager.shared.logIn(token: loginToken, type: .apple)
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
        return self.findPasswordUsecase.changePassword(eMail: email, currentPassword: tempPassword, newPassword: newPassword)
    }
    
    private func eMailLogIn(email: String, password: String) -> Observable<Result<EMailLogInSuccessType, ArchiveError>> {
        return self.emailLogInUsecase.loginEmail(eMail: email, password: password)
    }
    
    private func debugTouch() {
        self.debugTouchCnt += 1
        if debugTouchCnt >= 15 {
            self.showDebugPasswordInputView.onNext(())
        }
    }
    
    
}

struct LoginEmailParam: Encodable {
    var email: String
    var password: String
}

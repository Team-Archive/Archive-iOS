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
        case debugTouchAction
    }
     
    enum Mutation {
        case setID(String)
        case setPassword(String)
        case setIsVaildEmail(Bool)
        case setValidation(Bool)
        case setIsLoading(Bool)
        case empty
    }
    
    struct State {
        var id: String = ""
        var password: String = ""
        var isValidEmail: Bool = false
        var isEnableSignIn: Bool = false
        var isLoading: Bool = false
    }
    
    let initialState = State()
    let steps = PublishRelay<Step>()
    private let validator: Validator
    var error: PublishSubject<ArchiveError>
    var toastMessage: PublishSubject<String>
    var popToRootView: PublishSubject<Void>
    var showDebugPasswordInputView: PublishSubject<Void> = .init()
    private let oAuthUsecase: LoginOAuthUsecase
    private let findPasswordUsecase: FindPasswordUsecase
    let pop: PublishSubject<Void> = .init()
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
                        case .success(let logInSuccessData):
                            LogInManager.shared.logIn(
                                token: logInSuccessData.token,
                                type: .eMail
                            )
                            LogInManager.shared.refreshProfile()
                            self?.steps.accept(ArchiveStep.userIsSignedIn(isTempPw: logInSuccessData.isTempPW))
                        case .failure(let err):
                            self?.error.onNext(err)
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
                    self?.error.onNext(err)
                }
            }
            return .empty()
        case .signInWithKakao:
            getKakaoLoginToken { [weak self] result in
                switch result {
                case .success(let accessToken):
                    self?.action.onNext(.isExistIdCheckWithKakao(accessToken: accessToken))
                case .failure(let err):
                    self?.error.onNext(err)
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
                        self?.steps.accept(ArchiveStep.userIsSignedIn(isTempPw: false))
                    case .failure(let err):
                        self?.error.onNext(err)
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
                        self?.steps.accept(ArchiveStep.userIsSignedIn(isTempPw: false))
                    case .failure(let err):
                        self?.error.onNext(err)
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
                            self?.pop.onNext(())
                        } else {
                            self?.toastMessage.onNext("가입하지 않은 이메일입니다. 회원가입으로 이동해주세요.")
                        }
                    case .failure(let err):
                        self?.error.onNext(err)
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
    
    private func eMailLogIn(email: String, password: String) -> Observable<Result<EMailLogInSuccessData, ArchiveError>> {
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

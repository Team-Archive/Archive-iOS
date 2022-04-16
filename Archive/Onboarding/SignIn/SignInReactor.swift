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
    private let validator: SignInValidator
    var error: PublishSubject<String>
    private let oAuthUsecase: LoginOAuthUsecase
    
    init(validator: SignInValidator, loginOAuthRepository: LoginOAuthRepository) {
        self.validator = validator
        self.error = .init()
        self.oAuthUsecase = LoginOAuthUsecase(repository: loginOAuthRepository)
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
                        UserDefaultManager.shared.setLoginToken(token)
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
            print("로그인 ㄱ")
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
        self.oAuthUsecase.isExistEmailWithKakao(accessToken: accessToken)
    }
    
    
}

struct LoginEmailParam: Encodable {
    var email: String
    var password: String
}

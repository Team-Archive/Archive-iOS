//
//  MainSplashReactor.swift
//  Archive
//
//  Created by hanwe on 2022/05/14.
//

import ReactorKit
import RxSwift
import RxRelay
import RxFlow

class MainSplashReactor: Reactor, Stepper {
    
    enum Action {
        case autoLogin
        case setIsFinishAnimation
    }
    
    enum Mutation {
        case empty
        case setIsFinishAnimation(Bool)
        case setIsFinishAutoLogin(Bool)
        case setIsSuccessAutoLogin(Bool)
    }
    
    struct State {
        var isFinishAnimation: Bool = false
        var isFinishAutoLogin: Bool = false
        var isSuccessAutoLogin: Bool = false
    }
    
    // MARK: private property
    
    private let usecase: LoginAccessTokenUsecase
    
    // MARK: property
    
    let initialState = State()
    let steps = PublishRelay<Step>()
    
    // MARK: lifeCycle
    
    init(repository: LoginAccessTokenRepository) {
        self.usecase = LoginAccessTokenUsecase(repository: repository)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .autoLogin:
            return Observable.concat([
                self.isLoggedIn().map { [weak self] isLoggedIn in
                    self?.goToNextStep(isFinishAnimation: self?.currentState.isFinishAnimation ?? true,
                                 isFinishAutoLogin: true,
                                 isSuccessAutoLogin: isLoggedIn)
                    LogInManager.shared.refreshProfile()
                    return .setIsSuccessAutoLogin(isLoggedIn)
                },
                Observable.just(.setIsFinishAutoLogin(true))
            ])
        case .setIsFinishAnimation:
            goToNextStep(isFinishAnimation: true,
                         isFinishAutoLogin: self.currentState.isFinishAutoLogin,
                         isSuccessAutoLogin: self.currentState.isSuccessAutoLogin)
            return .just(.setIsFinishAnimation(true))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .empty:
            break
        case .setIsFinishAnimation(let isFinish):
            newState.isFinishAnimation = isFinish
        case .setIsFinishAutoLogin(let isFinish):
            newState.isFinishAutoLogin = isFinish
        case .setIsSuccessAutoLogin(let isSuccess):
            newState.isSuccessAutoLogin = isSuccess
        }
        return newState
    }
    
    // MARK: private func
    
    private func goToNextStep(isFinishAnimation: Bool, isFinishAutoLogin: Bool, isSuccessAutoLogin: Bool) {
        if isFinishAnimation && isFinishAutoLogin {
            if isSuccessAutoLogin {
                print("자동로그인 성공")
                self.steps.accept(ArchiveStep.successAutoLoggedIn)
            } else {
                print("자동로그인 실패")
                self.steps.accept(ArchiveStep.failAutoLoggedIn)
            }
        }
    }
    
    private func isLoggedIn() -> Observable<Bool> {
        if LogInManager.shared.isLoggedIn {
            return self.usecase.isValidAccessToken()
        } else {
            return .just(false)
        }
    }
    
    // MARK: func
    
    
    
    
}

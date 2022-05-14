//
//  WithdrawalReactor.swift
//  Archive
//
//  Created by hanwe on 2021/10/23.
//

import ReactorKit
import RxSwift
import RxRelay
import RxFlow

class WithdrawalReactor: Reactor, Stepper {
    // MARK: private property
    
    private let model: WithdrawalModelProtocol
    
    // MARK: internal property
    
    let steps = PublishRelay<Step>()
    let initialState = State()
    var err: PublishSubject<ArchiveError> = .init()
    
    // MARK: lifeCycle
    
    init(model: WithdrawalModelProtocol) {
        self.model = model
    }
    
    enum Action {
        case cardCnt
        case completion
        case withrawal
    }
    
    enum Mutation {
        case setCardCnt(Int)
        case setIsLoading(Bool)
    }
    
    struct State {
        var cardCnt: Int = 0
        var isLoading: Bool = false
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .cardCnt:
            let cnt = model.cardCount
            return .just(.setCardCnt(cnt))
        case .completion:
            steps.accept(ArchiveStep.withdrawalIsComplete)
            return .empty()
        case .withrawal:
            return Observable.concat([
                Observable.just(.setIsLoading(true)),
                self.withdrawal().map { [weak self] result in
                    switch result {
                    case .success(_):
                        LogInManager.shared.logOut()
                        self?.steps.accept(ArchiveStep.logout)
                    case .failure(let err):
                        self?.err.onNext(err)
                    }
                    return .setIsLoading(false)
                }
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setCardCnt(let cardCnt):
            newState.cardCnt = cardCnt
        case .setIsLoading(let isLoading):
            newState.isLoading = isLoading
        }
        return newState
    }
    
    // MARK: private function
    
    private func withdrawal() -> Observable<Result<Data, ArchiveError>> {
        let provider = ArchiveProvider.shared.provider
        
        return provider.rx.request(.withdrawal, callbackQueue: DispatchQueue.global())
            .asObservable()
            .map { result in
                return .success(result.data)
            }
            .catch { err in
                    .just(.failure(.init(from: .server, code: err.responseCode, message: err.archiveErrMsg)))
            }
    }
    
    // MARK: internal function
}

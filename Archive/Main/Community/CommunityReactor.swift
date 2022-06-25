//
//  CommunityReactor.swift
//  Archive
//
//  Created by hanwe on 2022/05/14.
//

import RxSwift
import RxRelay
import RxFlow
import ReactorKit

class CommunityReactor: Reactor, Stepper, MainTabStepperProtocol {
    
    // MARK: private property
    
    private let usecase: CommunityUsecase
    
    // MARK: internal property
    
    let steps = PublishRelay<Step>()
    let initialState = State()
    
    // MARK: lifeCycle
    
    init(repository: CommunityRepository) {
        self.usecase = CommunityUsecase(repository: repository)
    }
    
    enum Action {
        case endFlow
    }
    
    enum Mutation {
    }
    
    struct State {
        
        var isLoading: Bool = false
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .endFlow:
            self.steps.accept(ArchiveStep.communityIsComplete)
            return .empty()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
//        switch mutation {
//        case .setCardCnt(let cardCnt):
//            newState.cardCnt = cardCnt
//        case .setIsLoading(let isLoading):
//            newState.isLoading = isLoading
//        }
        return newState
    }
    
    // MARK: private function
    
    // MARK: internal function
    
    func runReturnEndFlow() {
        self.action.onNext(.endFlow)
    }
    
}

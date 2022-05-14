//
//  MainTabBarReactor.swift
//  Archive
//
//  Created by hanwe on 2022/05/14.
//

import ReactorKit
import RxSwift
import RxRelay
import RxFlow

class MainTabBarReactor: Reactor, Stepper {
    
    enum Action {
        case moveTo(_ tab: Tab)
    }
    
    enum Mutation {
    }
    
    struct State {
    }
    
    // MARK: private property
    
    // MARK: property
    
    let initialState = State()
    let steps = PublishRelay<Step>()
    var error: PublishSubject<ArchiveError>
    
    // MARK: lifeCycle
    
    init() {
        self.error = .init()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .moveTo(let tab):
            switch tab {
            case .home:
                self.steps.accept(ArchiveStep.homeIsRequired)
            case .record:
                return .empty()
            case .community:
                self.steps.accept(ArchiveStep.communityIsRequired)
            case .myPage:
                self.steps.accept(ArchiveStep.myPageIsRequired(0))
            case .none:
                break
            }
            return .empty()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        return state
    }
    
    // MARK: private func
    
    // MARK: func
    
    
    
    
}

//
//  EditProfileReactor.swift
//  Archive
//
//  Created by hanwe on 2022/09/24.
//

import ReactorKit
import RxSwift
import SwiftyJSON
import RxRelay
import RxFlow

class EditProfileReactor: Reactor, Stepper {
    
    // MARK: private property
    
    // MARK: internal property
    
    var steps: PublishRelay<Step> = PublishRelay<Step>()
    let initialState: State
    let err: PublishSubject<ArchiveError> = .init()
    
    // MARK: lifeCycle
    
    init() {
        self.initialState = .init()
    }
    
    enum Action {
        case endFlow
    }
    
    enum Mutation {
        case empty
        case setIsLoading(Bool)
    }
    
    struct State {
        var isLoading: Bool = false
        var myLikeArchives: [PublicArchive] = []
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .endFlow:
            self.steps.accept(ArchiveStep.editProfileIsComplete)
            return .empty()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
//        switch mutation {
//        }
        return newState
    }
    
    // MARK: private function
    
    // MARK: internal function
    
}

//
//  RegistReactor.swift
//  Archive
//
//  Created by Aaron Hanwe LEE on 2022/08/11.
//

import UIKit
import RxSwift
import RxRelay
import RxFlow
import ReactorKit

class RegistReactor: Reactor, Stepper {
    
    // MARK: private property
    
    // MARK: internal property
    
    let initialState: State = State()
    var steps: PublishRelay<Step>
    var err: PublishSubject<ArchiveError> = .init()
    
    enum Action {
        case setEmotion(Emotion)
    }
    
    enum Mutation {
        case empty
        case setEmotion(Emotion)
    }
    
    struct State {
        var emotion: Emotion?
    }
    
    // MARK: life cycle
    
    init() {
        self.steps = PublishRelay<Step>()
    }
    
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .setEmotion(let emotion):
            return .just(.setEmotion(emotion))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .empty:
            break
        case .setEmotion(let emotion):
            newState.emotion = emotion
        }
        return newState
    }
    
    // MARK: private func
    
    // MARK: internal func
    
}

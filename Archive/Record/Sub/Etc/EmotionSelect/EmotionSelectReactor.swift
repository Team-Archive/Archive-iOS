//
//  EmotionSelectReactor.swift
//  Archive
//
//  Created by hanwe lee on 2021/10/25.
//

import RxSwift
import ReactorKit
import RxRelay
import RxFlow

class EmotionSelectReactor: Reactor, Stepper {
    
    // MARK: private property
    
    // MARK: internal property
    
    let initialState = State()
    let steps = PublishRelay<Step>()
    let close: PublishSubject<Void> = .init()
    
    // MARK: lifeCycle
    
    init(currentEmotion: Emotion?) {
        if let emotion = currentEmotion {
            self.action.onNext(.select(emotion))
        }
    }
    
    enum Action {
        case select(Emotion)
        case completeEmotionEdit
    }
    
    enum Mutation {
        case setEmotion(Emotion)
    }
    
    struct State {
        var currentEmotion: Emotion = .pleasant
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .select(let emotion):
            return .just(.setEmotion(emotion))
        case .completeEmotionEdit:
            steps.accept(ArchiveStep.recordEmotionEditIsComplete(self.currentState.currentEmotion))
            self.close.onNext(())
            return .empty()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setEmotion(let emotion):
            newState.currentEmotion = emotion
        }
        return newState
    }
    
    // MARK: private function
    
    // MARK: internal function
}

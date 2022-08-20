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
        case setImages(RegistImagesInfo)
    }
    
    enum Mutation {
        case empty
        case setEmotion(Emotion)
        case setImages(RegistImagesInfo)
    }
    
    struct State {
        var emotion: Emotion?
        var images: RegistImagesInfo = RegistImagesInfo(images: [], isMoveFirstIndex: false)
    }
    
    // MARK: life cycle
    
    init() {
        self.steps = PublishRelay<Step>()
    }
    
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .setEmotion(let emotion):
            return .just(.setEmotion(emotion))
        case .setImages(let images):
            return .just(.setImages(images))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .empty:
            break
        case .setEmotion(let emotion):
            newState.emotion = emotion
        case .setImages(let images):
            newState.images = images
        }
        return newState
    }
    
    // MARK: private func
    
    // MARK: internal func
    
}

struct RegistImagesInfo: Equatable {
    var images: [UIImage]
    let isMoveFirstIndex: Bool // 스크롤 처음으로 돌아갈지 여부를 Bool로 표기
}

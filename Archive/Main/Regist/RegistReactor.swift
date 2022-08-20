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
        case setImageInfo(RegistImagesInfo)
    }
    
    enum Mutation {
        case empty
        case setEmotion(Emotion)
        case setImageInfo(RegistImagesInfo)
    }
    
    struct State {
        var emotion: Emotion?
        var imageInfo: RegistImagesInfo = RegistImagesInfo(images: [], isMoveFirstIndex: false)
    }
    
    // MARK: life cycle
    
    init() {
        self.steps = PublishRelay<Step>()
    }
    
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .setEmotion(let emotion):
            return .just(.setEmotion(emotion))
        case .setImageInfo(let info):
            return .just(.setImageInfo(info))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .empty:
            break
        case .setEmotion(let emotion):
            newState.emotion = emotion
        case .setImageInfo(let info):
            newState.imageInfo = info
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

struct RegistImageInfo: Equatable {
    var image: UIImage
    var color: UIColor
}

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
    
    private let imageColorUsecase = ImageColorUsecase()
    
    // MARK: internal property
    
    let initialState: State = State()
    var steps: PublishRelay<Step>
    var err: PublishSubject<ArchiveError> = .init()
    
    enum Action {
        case setEmotion(Emotion)
        case setImageInfo(RegistImagesInfo)
        case cropedImage(cropedimage: UIImage, index: Int)
        case setArchiveName(String)
        case setVisitDate(String)
        case setFriends(String)
        case setIsPublic(Bool)
        case setPhotoContents(index: Int, contents: String)
        case clearPhotoContents
    }
    
    enum Mutation {
        case empty
        case setEmotion(Emotion)
        case setImageInfo(RegistImagesInfo)
        case setIsLoading(Bool)
        case setArchiveName(String?)
        case setVisitDate(String?)
        case setFriends(String?)
        case setIsPublic(Bool)
        case setBehineViewConfirmIsEnable(Bool)
        case setPhotoContents(index: Int, contents: String)
        case clearPhotoContents
    }
    
    struct State {
        var emotion: Emotion?
        var imageInfo: RegistImagesInfo = RegistImagesInfo(images: [], isMoveFirstIndex: false)
        var isLoading: Bool = false
        var archiveName: String?
        var visitDate: String?
        var friends: String?
        var isPublic: Bool = false
        var isBehineViewConfirmIsEnable: Bool = false
        var photoContents: [Int: String] = [:]
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
        case .cropedImage(let cropedimage, let index):
            return Observable.concat([
                Observable.just(Mutation.setIsLoading(true)),
                self.imageColorUsecase.extractColor(images: [cropedimage])
                    .map { [weak self] result in
                        switch result {
                        case .success(let infos):
                            if var newImageInfos = self?.currentState.imageInfo.images {
                                newImageInfos.insert(infos[0], at: index)
                                newImageInfos.remove(at: index + 1)
                                self?.action.onNext(.setImageInfo(RegistImagesInfo(images: newImageInfos,
                                                                                   isMoveFirstIndex: false)))
                            }
                        case .failure(let err):
                            self?.err.onNext(err)
                        }
                        return .empty
                    },
                Observable.just(Mutation.setIsLoading(false))
            ])
        case .setArchiveName(let name):
            if name == "" {
                return .from([
                    .setArchiveName(nil),
                    .setBehineViewConfirmIsEnable(false)
                ])
            } else {
                let isEnable: Bool = self.currentState.visitDate == nil ? false : true
                return .from([
                    .setArchiveName(name),
                    .setBehineViewConfirmIsEnable(isEnable)
                ])
            }
        case .setVisitDate(let date):
            if date == "" {
                return .from([
                    .setVisitDate(nil),
                    .setBehineViewConfirmIsEnable(false)
                ])
            } else {
                let isEnable: Bool = self.currentState.archiveName == nil ? false : true
                return .from([
                    .setVisitDate(date),
                    .setBehineViewConfirmIsEnable(isEnable)
                ])
            }
        case .setFriends(let friends):
            if friends == "" {
                return .just(.setFriends(nil))
            } else {
                return .just(.setFriends(friends))
            }
        case .setIsPublic(let isPublic):
            return .just(.setIsPublic(isPublic))
        case .setPhotoContents(let index, let contents):
            return .just(.setPhotoContents(index: index, contents: contents))
        case .clearPhotoContents:
            return .just(.clearPhotoContents)
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
        case .setIsLoading(let isLoading):
            newState.isLoading = isLoading
        case .setArchiveName(let name):
            newState.archiveName = name
        case .setVisitDate(let date):
            newState.visitDate = date
        case .setFriends(let friends):
            newState.friends = friends
        case .setIsPublic(let isPublic):
            newState.isPublic = isPublic
        case .setBehineViewConfirmIsEnable(let isEnable):
            newState.isBehineViewConfirmIsEnable = isEnable
        case .setPhotoContents(let index, let contents):
            newState.photoContents[index] = contents
        case .clearPhotoContents:
            newState.photoContents.removeAll()
        }
        return newState
    }
    
    // MARK: private func
    
    // MARK: internal func
    
}

struct RegistImagesInfo: Equatable {
    var images: [RegistImageInfo]
    let isMoveFirstIndex: Bool // 스크롤 처음으로 돌아갈지 여부를 Bool로 표기
}

struct RegistImageInfo: Equatable {
    var image: UIImage
    var color: UIColor
}

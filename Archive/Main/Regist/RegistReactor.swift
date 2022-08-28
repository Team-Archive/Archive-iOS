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
import Photos

class RegistReactor: Reactor, Stepper {
    
    // MARK: private property
    
    private let imageColorUsecase = ImageColorUsecase()
    
    // MARK: internal property
    
    let initialState: State = State()
    var steps: PublishRelay<Step>
    var err: PublishSubject<ArchiveError> = .init()
    var moveToConfig: PublishSubject<Void> = .init()
    var photoAccessAuthSuccess: PublishSubject<Void> = .init()
    
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
        case requestPhotoAccessAuth
        case regist
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
        case setIsForegroundViewConfirmIsEnable(Bool)
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
        var isForegroundViewConfirmIsEnable: Bool = false
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
            let isEnableForegroundConfirm: Bool = info.images.count > 0 && self.currentState.isBehineViewConfirmIsEnable && self.currentState.emotion != nil
            return .from([
                .setIsForegroundViewConfirmIsEnable(isEnableForegroundConfirm),
                .setImageInfo(info)
            ])
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
                let isEnableBehindConfirm: Bool = self.currentState.visitDate == nil ? false : true
                let isEnableForegroundConfirm: Bool = isEnableBehindConfirm && self.currentState.imageInfo.images.count > 0
                return .from([
                    .setArchiveName(name),
                    .setBehineViewConfirmIsEnable(isEnableBehindConfirm),
                    .setIsForegroundViewConfirmIsEnable(isEnableForegroundConfirm)
                ])
            }
        case .setVisitDate(let date):
            if date == "" {
                return .from([
                    .setVisitDate(nil),
                    .setBehineViewConfirmIsEnable(false)
                ])
            } else {
                let isEnableBehindConfirm: Bool = self.currentState.archiveName == nil ? false : true
                let isEnableForegroundConfirm: Bool = isEnableBehindConfirm && self.currentState.imageInfo.images.count > 0
                return .from([
                    .setVisitDate(date),
                    .setBehineViewConfirmIsEnable(isEnableBehindConfirm),
                    .setIsForegroundViewConfirmIsEnable(isEnableForegroundConfirm)
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
        case .requestPhotoAccessAuth:
            self.checkPhotoAuth(completion: { [weak self] in
                self?.photoAccessAuthSuccess.onNext(())
            })
            return .empty()
        case .regist:
            self.steps.accept(ArchiveStep.registUploadIsRequired)
            return .empty()
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
        case .setIsForegroundViewConfirmIsEnable(let isEnable):
            newState.isForegroundViewConfirmIsEnable = isEnable
        }
        return newState
    }
    
    // MARK: private func
    
    private func checkPhotoAuth(completion: (() -> Void)?) {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            completion?()
        case .denied, .restricted :
            self.moveToConfig.onNext(())
        case .notDetermined:
            requestPhotoAuth(completion: completion)
        case .limited:
            break
        @unknown default:
            break
        }
    }
    
    private func requestPhotoAuth(completion: (() -> Void)?) {
        if #available(iOS 14, *) {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] (status) in
                switch status {
                case .authorized:
                    completion?()
                case .denied, .restricted, .notDetermined, .limited:
                    self?.err.onNext(.init(.photoAuth))
                @unknown default:
                    break
                }
            }
        } else {
            PHPhotoLibrary.requestAuthorization { [weak self] status in
                switch status {
                case .authorized:
                    completion?()
                case .denied, .restricted, .notDetermined, .limited:
                    self?.err.onNext(.init(.photoAuth))
                @unknown default:
                    break
                }
            }
        }
    }
    
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

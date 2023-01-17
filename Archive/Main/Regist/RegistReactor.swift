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
    private let uploadImageUsecase: UploadImageUsecase
    private lazy var registUsecase = RegistUsecase(repository: RegistRepositoryImplement(uploadImageUsecase: self.uploadImageUsecase))
    
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
        case registIsComplete
        case setOriginPhotoInfo([PHAsset: PhotoFromAlbumModel])
        case setIsUsingCover(Bool)
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
        case setOriginPhotoInfo([PHAsset: PhotoFromAlbumModel])
        case setIsUsingCover(Bool)
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
        var originPhotoInfo: [PHAsset: PhotoFromAlbumModel] = [:]
        var isCoverUsing: Bool = true
    }
    
    // MARK: life cycle
    
    init(uploadImageRepository: UploadImageRepository) {
        self.steps = PublishRelay<Step>()
        self.uploadImageUsecase = UploadImageUsecase(repository: uploadImageRepository)
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
            guard let name = self.currentState.archiveName,
                  let visitDate = self.currentState.visitDate,
                  let emotion = self.currentState.emotion else {
                err.onNext(.init(.archiveDataIsInvaild))
                return .just(.empty)
            }
            let registObservable = self.registUsecase.regist(
                name: name,
                watchedOn: visitDate,
                companions: friendsToFriendsArr(self.currentState.friends),
                emotion: emotion.rawStringValue,
                images: self.currentState.imageInfo.images,
                imageContents: self.currentState.photoContents,
                isPublic: self.currentState.isPublic,
                coverType: self.currentState.isCoverUsing ? .cover : .image
            ).map { [weak self] result -> RegistReactor.Mutation in
                switch result {
                case .success(_):
                    break
                case .failure(let err):
                    self?.err.onNext(err)
                }
                return .empty
            }
            let getThisMonthRegistCountObservable = self.registUsecase.getThisMonthRegistCnt()
                .map { result -> Result<Int, ArchiveError> in
                    switch result {
                    case .success(let cnt):
                        return .success(cnt)
                    case .failure(let err):
                        return .failure(err)
                    }
                }
            return Observable.zip(registObservable, getThisMonthRegistCountObservable).map { [weak self] result -> RegistReactor.Mutation in
                var thisMonthRegistCnt: Int = 0
                switch result.1 {
                case .success(let cnt):
                    thisMonthRegistCnt = cnt
                case .failure(_): // 오류처리 안함
                    break
                }
                GAModule.sendEventLogToGA(.completeRegistArchive)
                self?.steps.accept(ArchiveStep.registCompleteIsRequired(thisMonthRegistCnt: thisMonthRegistCnt))
                return .empty
            }
        case .registIsComplete:
            NotificationCenter.default.post(name: Notification.Name(NotificationDefine.ARCHIVE_IS_ADDED), object: nil)
            self.steps.accept(ArchiveStep.registIsComplete)
            return .empty()
        case .setOriginPhotoInfo(let info):
            return .just(.setOriginPhotoInfo(info))
        case .setIsUsingCover(let isUsing):
            return .just(.setIsUsingCover(isUsing))
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
        case .setOriginPhotoInfo(let info):
            newState.originPhotoInfo = info
        case .setIsUsingCover(let isUsing):
            newState.originPhotoInfo = [:]
            newState.isCoverUsing = isUsing
            newState.photoContents.removeAll()
            newState.imageInfo = .init(images: [], isMoveFirstIndex: true)
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
    //
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
    
    private func friendsToFriendsArr(_ friendsString: String?) -> [String]? {
        guard let friendsString = friendsString else { return nil }
        let tmpValue = friendsString.split(separator: ",")
        let returnValue: [String] = {
            var returnValue: [String] = []
            for item in tmpValue {
                returnValue.append(String(item))
            }
            return returnValue
        }()
        return returnValue
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

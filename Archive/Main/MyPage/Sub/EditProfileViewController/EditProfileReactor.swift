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
import Photos

class EditProfileReactor: Reactor, Stepper {
    
    // MARK: private property
    
    private let nickNameCheckUsecase: NickNameDuplicationUsecase
    private let updateProfileUsecase: UpdateProfileUsecase
    private var isUploading: Bool = false
    
    // MARK: internal property
    
    var steps: PublishRelay<Step> = PublishRelay<Step>()
    let initialState: State
    let err: PublishSubject<ArchiveError> = .init()
    var photoAccessAuthSuccess: PublishSubject<Void> = .init()
    var moveToConfig: PublishSubject<Void> = .init()
    var updateProfileComplete: PublishSubject<Void> = .init()
    
    // MARK: lifeCycle
    
    init(nickNameDuplicationRepository: NickNameDuplicationRepository, updateProfileRepository: UpdateProfileRepository, uploadImageRepository: UploadImageRepository) {
        self.initialState = .init()
        self.nickNameCheckUsecase = NickNameDuplicationUsecase(repository: nickNameDuplicationRepository)
        self.updateProfileUsecase = UpdateProfileUsecase(repository: updateProfileRepository, uploadImageRepository: uploadImageRepository)
    }
    
    enum Action {
        case endFlow
        case checkIsDuplicatedNickName(String)
        case changedNickNameText
        case requestPhotoAccessAuth
        case setProfileImageData(Data)
        case updateProfile
    }
    
    enum Mutation {
        case empty
        case setIsLoading(Bool)
        case setIsEnableConfirmBtn(Bool)
        case setIsDuplicatedNickName(Bool?)
        case setNewNickName(String)
        case setIsRegistNewProfilePhoto(Bool)
        case setProfileImageData(Data)
    }
    
    struct State {
        var isLoading: Bool = false
        var myLikeArchives: [PublicArchive] = []
        var isDuplicatedNickName: Bool?
        var isRegistNewProfilePhoto: Bool = false
        var isEnableConfirmBtn: Bool = false
        var newNickName: String = ""
        var profileImageData: Data?
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .endFlow:
            self.steps.accept(ArchiveStep.editProfileIsComplete)
            return .empty()
        case .checkIsDuplicatedNickName(let nickName):
            return Observable.concat([
                Observable.just(Mutation.setIsLoading(true)),
                self.isDuplicatedNickName(nickName)
                    .map { result -> Result<Bool, ArchiveError> in
                        switch result {
                        case .success(let isDuplicated):
                            return .success(isDuplicated)
                        case .failure(let err):
                            return .failure(err)
                        }
                    }
                    .flatMap { [weak self] result -> Observable<Mutation> in
                        switch result {
                        case .success(let isDuplicated):
                            if isDuplicated {
                                let confirmBtnIsEnable: Bool = self?.checkConfirmBtnIsEnable(isCheckedNickNameDuplication: false,
                                                                                            isRegistedNewProfilePhoto: self?.currentState.isRegistNewProfilePhoto ?? false) ?? false
                                return .from([
                                    .setNewNickName(""),
                                    .setIsDuplicatedNickName(true),
                                    .setIsEnableConfirmBtn(confirmBtnIsEnable)
                                ])
                            } else {
                                let confirmBtnIsEnable: Bool = self?.checkConfirmBtnIsEnable(isCheckedNickNameDuplication: true,
                                                                                            isRegistedNewProfilePhoto: self?.currentState.isRegistNewProfilePhoto ?? false) ?? false
                                return .from([
                                    .setIsDuplicatedNickName(false),
                                    .setNewNickName(nickName),
                                    .setIsEnableConfirmBtn(confirmBtnIsEnable)
                                ])
                            }
                        case .failure(let err):
                            self?.err.onNext(err)
                            return .empty()
                        }
                    }
                ,
                Observable.just(Mutation.setIsLoading(false))
            ])
        case .changedNickNameText:
            let confirmBtnIsEnable: Bool = self.checkConfirmBtnIsEnable(isCheckedNickNameDuplication: false,
                                                                        isRegistedNewProfilePhoto: self.currentState.isRegistNewProfilePhoto)
            return .from([
                .setIsEnableConfirmBtn(confirmBtnIsEnable),
                .setNewNickName(""),
                .setIsDuplicatedNickName(nil)
            ])
        case .requestPhotoAccessAuth:
            self.checkPhotoAuth(completion: { [weak self] in
                self?.photoAccessAuthSuccess.onNext(())
            })
            return .empty()
        case .setProfileImageData(let data):
            let confirmBtnIsEnable: Bool = self.checkConfirmBtnIsEnable(isCheckedNickNameDuplication: self.currentState.isDuplicatedNickName ?? false,
                                                                        isRegistedNewProfilePhoto: true)
            return .from([
                .setIsEnableConfirmBtn(confirmBtnIsEnable),
                .setIsRegistNewProfilePhoto(true),
                .setProfileImageData(data)
            ])
        case .updateProfile:
            self.isUploading = true
            return Observable.concat([
                Observable.just(Mutation.setIsLoading(true)),
                Observable.just(Mutation.setIsEnableConfirmBtn(false)),
                self.updateProfile(profileImageData: self.currentState.profileImageData,
                                   nickName: self.currentState.newNickName)
                .map { [weak self] result in
                    switch result {
                    case .success(let updateProfileResult):
                        LogInManager.shared.profile = updateProfileResult
                        self?.updateProfileComplete.onNext(())
                        self?.steps.accept(ArchiveStep.editProfileIsComplete)
                    case .failure(let err):
                        self?.err.onNext(err)
                    }
                    return .empty
                },
                Observable.just(Mutation.setIsLoading(false))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .empty:
            break
        case .setIsLoading(let isLoading):
            newState.isLoading = isLoading
        case .setIsEnableConfirmBtn(let isEnable):
            newState.isEnableConfirmBtn = isEnable
        case .setIsDuplicatedNickName(let isDuplicated):
            newState.isDuplicatedNickName = isDuplicated
        case .setIsRegistNewProfilePhoto(let isRegisted):
            newState.isRegistNewProfilePhoto = isRegisted
        case .setNewNickName(let nickName):
            newState.newNickName = nickName
        case .setProfileImageData(let data):
            newState.profileImageData = data
        }
        return newState
    }
    
    // MARK: private function
    
    private func isDuplicatedNickName(_ nickName: String) -> Observable<Result<Bool, ArchiveError>> {
        return self.nickNameCheckUsecase.isDuplicatedNickName(nickName)
    }
    
    private func updateProfile(profileImageData: Data?, nickName: String) -> Observable<Result<ProfileData, ArchiveError>> {
        return self.updateProfileUsecase.updateProfile(imageData: profileImageData,
                                                       nickName: nickName)
    }
    
    private func checkConfirmBtnIsEnable(isCheckedNickNameDuplication: Bool, isRegistedNewProfilePhoto: Bool) -> Bool {
        if self.isUploading {
            return false
        } else {
            return isCheckedNickNameDuplication || isRegistedNewProfilePhoto
        }
    }
    
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
    
    // MARK: internal function
    
}

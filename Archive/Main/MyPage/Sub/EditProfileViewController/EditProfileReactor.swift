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
    
    private let nickNameCheckUsecase: NickNameDuplicationUsecase
    
    // MARK: internal property
    
    var steps: PublishRelay<Step> = PublishRelay<Step>()
    let initialState: State
    let err: PublishSubject<ArchiveError> = .init()
    
    // MARK: lifeCycle
    
    init(nickNameDuplicationRepository: NickNameDuplicationRepository) {
        self.initialState = .init()
        self.nickNameCheckUsecase = NickNameDuplicationUsecase(repository: nickNameDuplicationRepository)
    }
    
    enum Action {
        case endFlow
        case checkIsDuplicatedNickName(String)
        case changedNickNameText
    }
    
    enum Mutation {
        case empty
        case setIsLoading(Bool)
        case setIsEnableConfirmBtn(Bool)
        case setIsDuplicatedNickName(Bool?)
        case setNewNickName(String)
        case setIsRegistNewProfilePhoto(Bool)
    }
    
    struct State {
        var isLoading: Bool = false
        var myLikeArchives: [PublicArchive] = []
        var isDuplicatedNickName: Bool?
        var isRegistNewProfilePhoto: Bool = false
        var isEnableConfirmBtn: Bool = false
        var newNickName: String = ""
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
        }
        return newState
    }
    
    // MARK: private function
    
    private func isDuplicatedNickName(_ nickName: String) -> Observable<Result<Bool, ArchiveError>> {
        return self.nickNameCheckUsecase.isDuplicatedNickName(nickName)
    }
    
    private func checkConfirmBtnIsEnable(isCheckedNickNameDuplication: Bool, isRegistedNewProfilePhoto: Bool) -> Bool {
        return isCheckedNickNameDuplication || isRegistedNewProfilePhoto
    }
    
    // MARK: internal function
    
}

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
    }
    
    enum Mutation {
        case empty
        case setIsLoading(Bool)
        case setIsEnableConfirmBtn(Bool)
        case setIsDuplicatedNickName(Bool)
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
                                return .just(.setIsDuplicatedNickName(true))
                            } else {
                                return .from([
                                    .setIsDuplicatedNickName(true),
                                    .setNewNickName(nickName),
                                    .setIsEnableConfirmBtn(true)
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
    
    // MARK: internal function
    
}

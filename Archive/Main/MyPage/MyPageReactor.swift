//
//  MyPageReactor.swift
//  Archive
//
//  Created by hanwe on 2021/10/21.
//

import ReactorKit
import RxSwift
import RxRelay
import RxFlow
import SwiftyJSON

class MyPageReactor: Reactor, Stepper, MainTabStepperProtocol {
    
    // MARK: private property
    
    private let usecase: MyPageUsecase
    private let myLikeUsecase: MyLikeUsecase
    private let detailUsecase: DetailUsecase
    
    // MARK: internal property
    
    let steps = PublishRelay<Step>()
    let initialState: State
    let err: PublishSubject<ArchiveError> = .init()
    
    // MARK: lifeCycle
    
    init(repository: MyPageRepository, myLikeRepository: MyLikeRepository, detailRepository: DetailRepository) {
        self.initialState = .init()
        self.usecase = MyPageUsecase(repository: repository)
        self.myLikeUsecase = MyLikeUsecase(repository: myLikeRepository)
        self.detailUsecase = DetailUsecase(repository: detailRepository)
    }
    
    enum Action {
        case endFlow
        case moveToLoginInfo
        case openTerms
        case openPrivacy
        case openAboutInfo
        case moveToLikeList
        case getMyLikeArchives
        case moveToEditProfile
        case moveToCommunityTab
        case myLikeArchivesLikeCancel(id: Int)
        case showDetail(archiveId: Int)
    }
    
    enum Mutation {
        case empty
        case setIsLoading(Bool)
        case setMyLikeArchives([PublicArchive])
        case myLikeArchivesLikeCancel(id: Int)
    }
    
    struct State {
        var isLoading: Bool = false
        var myLikeArchives: [PublicArchive] = []
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .endFlow:
            self.steps.accept(ArchiveStep.myPageIsComplete)
            return .empty()
        case .moveToLikeList:
            self.steps.accept(ArchiveStep.myLikeListIsRequired(reactor: self))
            return .empty()
        case .moveToLoginInfo:
            return Observable.concat([
                Observable.just(.setIsLoading(true)),
                self.getCurrentUserInfo().map { [weak self] result in
                    switch result {
                    case .success(let info):
                        self?.steps.accept(ArchiveStep.loginInfomationIsRequired(stepper: self?.steps ?? .init(),
                                                                                 info: info))
                    case .failure(let err):
                        self?.err.onNext(err)
                    }
                    return .empty
                },
                Observable.just(.setIsLoading(false))
            ])
        case .openTerms:
            guard let url = URL(string: "https://wise-icicle-d10.notion.site/8ad4c5884b814ff6a6330f1a6143c1e6") else { return .empty()}
            self.steps.accept(ArchiveStep.openUrlIsRequired(url: url, title: "이용약관"))
            return .empty()
        case .openPrivacy:
            guard let url = URL(string: "https://wise-icicle-d10.notion.site/13ff403ad4e2402ca657fb20be31e4ae") else { return .empty()}
            self.steps.accept(ArchiveStep.openUrlIsRequired(url: url, title: "개인정보 처리방침"))
            return .empty()
        case .openAboutInfo:
            guard let url = URL(string: "https://wise-icicle-d10.notion.site/f4d7fb67e93345d8be5978d9327f0c2a") else { return .empty()}
            self.steps.accept(ArchiveStep.openUrlIsRequired(url: url, title: "아카이브 소개"))
            return .empty()
        case .getMyLikeArchives:
            return Observable.concat([
                Observable.just(.setIsLoading(true)),
                self.getMyLikeArchives().map { [weak self] result in
                    switch result {
                    case .success(let archives):
                        return .setMyLikeArchives(archives)
                    case .failure(let err):
                        self?.err.onNext(err)
                        return .empty
                    }
                },
                Observable.just(.setIsLoading(false))
            ])
        case .moveToEditProfile:
            self.steps.accept(ArchiveStep.editProfileIsRequired(reactor: self))
            return .empty()
        case .moveToCommunityTab:
            self.steps.accept(ArchiveStep.communityIrRequiredFromCode)
            return .empty()
        case .myLikeArchivesLikeCancel(let id):
            return .just(.myLikeArchivesLikeCancel(id: id))
        case .showDetail(let archiveId):
            return Observable.concat([
                Observable.just(.setIsLoading(true)),
                self.getDetailArchiveInfo(archiveId: archiveId).map { [weak self] result in
                    switch result {
                    case .success(let info):
                        self?.steps.accept(ArchiveStep.myLikeArchiveDetailIsRequired(data: info))
                    case .failure(let err):
                        self?.err.onNext(err)
                    }
                    return .empty
                },
                Observable.just(.setIsLoading(false))
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
        case .setMyLikeArchives(let archives):
            newState.myLikeArchives = archives
        case .myLikeArchivesLikeCancel(let id):
            newState.myLikeArchives = state.myLikeArchives.filter({ $0.archiveId != id })
        }
        return newState
    }
    
    // MARK: private function
    
    private func getCurrentUserInfo() -> Observable<Result<MyLoginInfo, ArchiveError>> {
        return self.usecase.getCurrentUserInfo()
    }
    
    private func getMyLikeArchives() -> Observable<Result<[PublicArchive], ArchiveError>> {
        return self.myLikeUsecase.getMyLikeArchives()
    }
    
    private func getDetailArchiveInfo(archiveId: Int) -> Observable<Result<ArchiveDetailInfo, ArchiveError>> {
        return self.detailUsecase.getDetailArchiveInfo(id: "\(archiveId)")
    }
    
    
    // MARK: internal function
    
    func runReturnEndFlow() {
        self.action.onNext(.endFlow)
    }
    
}

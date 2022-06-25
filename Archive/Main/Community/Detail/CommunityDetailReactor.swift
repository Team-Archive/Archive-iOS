//
//  CommunityDetailReactor.swift
//  Archive
//
//  Created by hanwe on 2022/06/25.
//

import RxSwift
import RxRelay
import RxFlow
import ReactorKit

class CommunityDetailReactor: Reactor, Stepper {
    
    // MARK: private property
    
    private let communityUsecase: CommunityUsecase
    private let likeUsecase: LikeUsecase
    
    // MARK: internal property
    
    let steps = PublishRelay<Step>()
    let initialState = State()
    var err: PublishSubject<ArchiveError> = .init()
    
    // MARK: lifeCycle
    
    init(communityRepository: CommunityRepository, likeRepository: LikeRepository) {
        self.communityUsecase = CommunityUsecase(repository: communityRepository)
        self.likeUsecase = LikeUsecase(repository: likeRepository)
    }
    
    enum Action {
        case endFlow
        case getPublicArchives(sortBy: PublicArchiveSortBy, emotion: Emotion?)
        case like(archiveId: Int, index: Int)
        case unlike(archiveId: Int, index: Int)
    }
    
    enum Mutation {
        case empty
        case setIsLoading(Bool)
        case setIsShimmerLoading(Bool)
        case setArchives([PublicArchive])
    }
    
    struct State {
        var isLoading: Bool = false
        var isShimmerLoading: Bool = false
        var archives: [PublicArchive] = []
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .endFlow:
            self.steps.accept(ArchiveStep.communityIsComplete)
            return .empty()
        case .getPublicArchives(sortBy: let sortBy, emotion: let emotion):
            return Observable.concat([
                Observable.just(Mutation.setIsShimmerLoading(true)),
                getPublicArchives(sortBy: sortBy, emotion: emotion)
                    .map { [weak self] result in
                        switch result {
                        case .success(let archiveInfo):
                            self?.usecase.setLastInfo(lastSeenArchiveDateMilli: archiveInfo.last?.dateMilli ?? 0,
                                                      lastSeenArchiveId: archiveInfo.last?.archiveId ?? 0)
                            return .setArchives(archiveInfo)
                        case .failure(let err):
                            self?.err.onNext(err)
                            return .empty
                        }
                    },
                Observable.just(Mutation.setIsShimmerLoading(false))
            ])
        case .like(archiveId: let archiveId, let index):
            return self.like(archiveId: archiveId)
                .map { [weak self] result in
                    switch result {
                    case .success(()):
                        guard let refreshResult = self?.refreshArchivesForIsLike(index: index, isLike: true) else { return .empty }
                        switch refreshResult {
                        case .success(let newArchives):
                            return .setArchives(newArchives)
                        case .failure(_):
                            break // 딱히 오류를 출력해주지는 않는다.
                        }
                    case .failure(let err):
                        print("err!!!!:\(err)") // 딱히 오류를 출력해주지는 않는다.
                    }
                    return .empty
                }
        case .unlike(archiveId: let archiveId, let index):
            return self.unlike(archiveId: archiveId)
                .map { [weak self] result in
                    switch result {
                    case .success(()):
                        guard let refreshResult = self?.refreshArchivesForIsLike(index: index, isLike: true) else { return .empty }
                        switch refreshResult {
                        case .success(let newArchives):
                            return .setArchives(newArchives)
                        case .failure(_):
                            break // 딱히 오류를 출력해주지는 않는다.
                        }
                    case .failure(let err):
                        print("err!!!!:\(err)") // 딱히 오류를 출력해주지는 않는다.
                    }
                    return .empty
                }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .empty:
            break
        case .setIsLoading(let isLoading):
            newState.isLoading = isLoading
        case .setIsShimmerLoading(let isLoading):
            newState.isShimmerLoading = isLoading
        case .setArchives(let archives):
            newState.archives = archives
        }
        return newState
    }
    
    // MARK: private function
    
    private func getPublicArchives(sortBy: PublicArchiveSortBy, emotion: Emotion?) -> Observable<Result<[PublicArchive], ArchiveError>> {
        return self.usecase.getPublicArchives(sortBy: sortBy, emotion: emotion)
    }
    
    private func like(archiveId: Int) -> Observable<Result<Void, ArchiveError>> {
        return self.likeUsecase.like(archiveId: archiveId)
    }
    
    private func unlike(archiveId: Int) -> Observable<Result<Void, ArchiveError>> {
        return self.likeUsecase.unlike(archiveId: archiveId)
    }
    
    private func refreshArchivesForIsLike(index: Int, isLike: Bool) -> Result<[PublicArchive], ArchiveError> {
        var returnValue = self.currentState.archives
        if self.currentState.archives.count > index + 1 {
            return .failure(.init(.publicArchiveIsRefreshed))
        } else {
            returnValue[index].isLiked = isLike
            return .success(returnValue)
        }
    }
    
    // MARK: internal function
    
    func runReturnEndFlow() {
        self.action.onNext(.endFlow)
    }
    
}
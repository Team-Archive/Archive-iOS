//
//  CommunityReactor.swift
//  Archive
//
//  Created by hanwe on 2022/05/14.
//

import RxSwift
import RxRelay
import RxFlow
import ReactorKit

class CommunityReactor: Reactor, Stepper, MainTabStepperProtocol {
    
    struct DetailInfo: Equatable {
        let archiveInfo: ArchiveDetailInfo
        let index: Int
    }
    
    // MARK: private property
    
    private let usecase: CommunityUsecase
    private let likeUsecase: LikeUsecase
    private let detailUsecase: DetailUsecase
    private var publicArchiveSortBy: PublicArchiveSortBy = .createdAt
    
    private var currentDetailIndex: Int = 0
    private var currentDetailInnerIndex: Int = 0
    
    // MARK: internal property
    
    let steps = PublishRelay<Step>()
    let initialState = State()
    var err: PublishSubject<ArchiveError> = .init()
    
    // MARK: lifeCycle
    
    init(repository: CommunityRepository, likeRepository: LikeRepository, detailRepository: DetailRepository) {
        self.usecase = CommunityUsecase(repository: repository)
        self.likeUsecase = LikeUsecase(repository: likeRepository)
        self.detailUsecase = DetailUsecase(repository: detailRepository)
    }
    
    enum Action {
        case endFlow
        case getPublicArchives(sortBy: PublicArchiveSortBy, emotion: Emotion?)
        case like(archiveId: Int)
        case unlike(archiveId: Int)
        case refreshLikeData(index: Int, isLike: Bool)
        case showDetail(index: Int)
        case spreadDetailData(infoData: ArchiveDetailInfo, index: Int)
        case showNextPage
        case showBeforePage
    }
    
    enum Mutation {
        case empty
        case setIsLoading(Bool)
        case setIsShimmerLoading(Bool)
        case setArchives([PublicArchive])
        case setDetailArchive(DetailInfo)
    }
    
    struct State {
        var isLoading: Bool = false
        var isShimmerLoading: Bool = false
        var archives: [PublicArchive] = []
        var detailArchive: DetailInfo = DetailInfo(
            archiveInfo: .init(archiveId: 0, authorId: 0, name: "", watchedOn: "", emotion: .fun, companions: nil, mainImage: "", images: nil),
            index: 0)
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
        case .like(archiveId: let archiveId):
            return self.like(archiveId: archiveId)
                .map { [weak self] result in
                    switch result {
                    case .success(()):
                        // 특별히 액션이 없다.
                        break
                    case .failure(let err):
                        print("err!!!!:\(err)") // 딱히 오류를 출력해주지는 않는다.
                    }
                    return .empty
                }
        case .unlike(archiveId: let archiveId):
            return self.unlike(archiveId: archiveId)
                .map { [weak self] result in
                    switch result {
                    case .success(()):
                        // 특별히 액션이 없다.
                        break
                    case .failure(let err):
                        print("err!!!!:\(err)") // 딱히 오류를 출력해주지는 않는다.
                    }
                    return .empty
                }
        case .refreshLikeData(let index, let isLike):
            let refreshResult = self.refreshArchivesForIsLike(index: index, isLike: isLike)
            switch refreshResult {
            case .success(let newArchives):
                return .just(.setArchives(newArchives))
            case .failure(_):
                break // 딱히 오류를 출력해주지는 않는다.
            }
            return .empty()
        case .showDetail(let index):
            return Observable.concat([
                Observable.just(Mutation.setIsShimmerLoading(true)),
                getDetailArchiveInfo(index: index).map { [weak self] result in
                    switch result {
                    case .success(let detailData):
                        self?.currentDetailIndex = index
                        self?.steps.accept(ArchiveStep.communityDetailIsRequired(
                            data: detailData,
                            currentIndex: index,
                            reactor: self ?? CommunityReactor(repository: CommunityRepositoryImplement(),
                                                              likeRepository: LikeRepositoryImplement(),
                                                              detailRepository: DetailRepositoryImplement())))
                    case .failure(let err):
                        self?.err.onNext(err)
                    }
                    return .empty
                },
                Observable.just(Mutation.setIsShimmerLoading(false))
            ])
        case .spreadDetailData(let infoData, let index):
            self.currentDetailIndex = index
            self.currentDetailInnerIndex = 0
            return .just(.setDetailArchive(DetailInfo(archiveInfo: infoData, index: self.currentDetailInnerIndex)))
        case .showNextPage:
            self.currentDetailInnerIndex += 1
            if let photoImageData = self.currentState.detailArchive.archiveInfo.images { // 포토 데이터가 있으면
                if photoImageData.count + 1 <= self.currentDetailInnerIndex { // 인덱스 초과, 다음 데이터로 넘어간다.
                    print("인덱스 초과 다음 데이터로 넘어간다.")
                    self.currentDetailInnerIndex = 0
                } else {
                    return .just(.setDetailArchive(DetailInfo(archiveInfo: self.currentState.detailArchive.archiveInfo,
                                                              index: self.currentDetailInnerIndex)))
                }
            } else { // 포토 데이터가 없다면
                // 다음 데이터로 넘어가본다.
                print("다음 데이터로 넘어간다.")
                self.currentDetailInnerIndex = 0
            }
            return .empty()
        case .showBeforePage:
            if self.currentDetailInnerIndex == 0 {
                if self.currentDetailIndex == 0 {
                    return .empty() // 현재 첫 번째 사진의 첫번째 인덱스인경우 아무것도 하지 않는다.
                } else {
                    self.currentDetailInnerIndex = 0 // 사진의 인덱스를 0으로 바꿔준다.
                    self.currentDetailIndex -= 1 // 이전 사진 데이터를 선택한다.
                    self.currentState.archives[self.currentDetailIndex] // 이 데이터의 디테일 정보를 얻어와야한다.
//                    self.action.onNext(.spreadDetailData(infoData: ,
//                                                         index: self.currentDetailInnerIndex))
                    print("이전 데이터로 넘어간다.")
                }
            } else {
                self.currentDetailInnerIndex -= 1
                return .just(.setDetailArchive(DetailInfo(archiveInfo: self.currentState.detailArchive.archiveInfo,
                                                          index: self.currentDetailInnerIndex)))
            }
            return .empty()
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
        case .setDetailArchive(let data):
            newState.detailArchive = data
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
            returnValue[index].isLiked = isLike
            return .success(returnValue)
        } else {
            return .failure(.init(.publicArchiveIsRefreshed))
        }
    }
    
    private func getDetailArchiveInfo(index: Int) -> Observable<Result<ArchiveDetailInfo, ArchiveError>> {
        if self.currentState.archives.count > index + 1 {
            return self.detailUsecase.getDetailArchiveInfo(id: "\(self.currentState.archives[index].archiveId)")
        } else {
            return .just(.failure(.init(.publicArchiveIsRefreshed)))
        }
    }
    
    // MARK: internal function
    
    func runReturnEndFlow() {
        self.action.onNext(.endFlow)
    }
    
}

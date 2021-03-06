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
import Kingfisher

class CommunityReactor: Reactor, Stepper, MainTabStepperProtocol {
    
    struct DetailInfo: Equatable {
        let archiveInfo: ArchiveDetailInfo
        let index: Int
    }
    
    // MARK: private property
    
    private let usecase: CommunityUsecase
    private let bannerUsecase: BannerUsecase
    private let likeUsecase: LikeUsecase
    private let detailUsecase: DetailUsecase
    private var archiveSortType: ArchiveSortType = .sortByRegist
    private var filterEmotion: Emotion?
    
    private(set) var currentDetailIndex: Int = 0
    private var currentDetailInnerIndex: Int = 0
    
    // MARK: internal property
    
    let steps = PublishRelay<Step>()
    let initialState = State()
    var err: PublishSubject<ArchiveError> = .init()
    
    // MARK: lifeCycle
    
    init(repository: CommunityRepository, bannerRepository: BannerRepository, likeRepository: LikeRepository, detailRepository: DetailRepository) {
        self.usecase = CommunityUsecase(repository: repository)
        self.bannerUsecase = BannerUsecase(repository: bannerRepository)
        self.likeUsecase = LikeUsecase(repository: likeRepository)
        self.detailUsecase = DetailUsecase(repository: detailRepository)
    }
    
    enum Action {
        case endFlow
        case getFirstPublicArchives(sortBy: ArchiveSortType, emotion: Emotion?)
        case getMorePublicArchives
        case refreshPublicArchives
        case like(archiveId: Int)
        case unlike(archiveId: Int)
        case refreshLikeData(index: Int, isLike: Bool)
        case showDetail(index: Int)
        case spreadDetailData(infoData: ArchiveDetailInfo, index: Int)
        case showNextPage
        case showBeforePage
        case showNextUser
        case showBeforeUser
        case getBannerInfo
        case bannerClicked(index: Int)
    }
    
    enum Mutation {
        case empty
        case setIsLoading(Bool)
        case setIsShimmerLoading(Bool)
        case setArchives([PublicArchive])
        case clearDetailArchive
        case setDetailArchive(DetailInfo)
        case setCurrentDetailUserNickName(String)
        case setCurrentDetailUserImage(String)
        case setDetailsIsLike(Bool)
        case setBannerInfo([BannerInfo])
        case appendArchives([PublicArchive])
    }
    
    struct State {
        var isLoading: Bool = false
        var isShimmerLoading: Bool = false
        var archives: Pulse<[PublicArchive]> = Pulse(wrappedValue: [])
        var detailArchive: DetailInfo = DetailInfo(
            archiveInfo: .init(archiveId: 0, authorId: 0, name: "", watchedOn: "", emotion: .fun, companions: nil, mainImage: "", images: nil),
            index: 0)
        var currentDetailUserNickName: String = ""
        var currentDetailUserImage: String = ""
        var detailIsLike: Bool = false
        var archiveTimeSortBy: ArchiveSortType = .sortByRegist
        var archiveEmotionSortBy: Emotion?
        var bannerInfo: [BannerInfo] = []
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .endFlow:
            self.steps.accept(ArchiveStep.communityIsComplete)
            return .empty()
        case .getFirstPublicArchives(sortBy: let sortBy, emotion: let emotion):
            return Observable.concat([
                Observable.just(Mutation.setIsShimmerLoading(true)),
                getFirstPublicArchives(sortBy: sortBy, emotion: emotion)
                    .map { [weak self] result in
                        switch result {
                        case .success(let archiveInfo):
                            return .setArchives(archiveInfo)
                        case .failure(let err):
                            self?.err.onNext(err)
                            return .empty
                        }
                    },
                Observable.just(Mutation.setIsShimmerLoading(false))
            ])
        case .refreshPublicArchives:
            return Observable.concat([
                Observable.just(Mutation.setIsLoading(true)),
                getFirstPublicArchives(sortBy: self.archiveSortType, emotion: self.filterEmotion)
                    .map { [weak self] result in
                        switch result {
                        case .success(let archiveInfo):
                            return .setArchives(archiveInfo)
                        case .failure(let err):
                            self?.err.onNext(err)
                            return .empty
                        }
                    },
                Observable.just(Mutation.setIsLoading(false))
            ])
        case .getMorePublicArchives:
            if !self.usecase.isQuerying && !self.usecase.isEndOfPage {
                return Observable.concat([
                    Observable.just(Mutation.setIsLoading(true)),
                    getMorePublicArchives()
                        .map { [weak self] result in
                            switch result {
                            case .success(let archives):
                                if (self?.currentState.archives.value.count ?? 0) == 0 {
                                    return .empty
                                } else {
                                    return .appendArchives(archives)
                                }
                            case .failure(let err):
                                self?.err.onNext(err)
                                return .empty
                            }
                        },
                    Observable.just(Mutation.setIsLoading(false))
                ])
            } else {
                return .empty()
            }
        case .like(archiveId: let archiveId):
            return self.like(archiveId: archiveId)
                .map { [weak self] result in
                    switch result {
                    case .success(()):
                        // ????????? ????????? ??????.
                        break
                    case .failure(let err):
                        print("err!!!!:\(err)") // ?????? ????????? ?????????????????? ?????????.
                    }
                    return .empty
                }
        case .unlike(archiveId: let archiveId):
            return self.unlike(archiveId: archiveId)
                .map { [weak self] result in
                    switch result {
                    case .success(()):
                        // ????????? ????????? ??????.
                        break
                    case .failure(let err):
                        print("err!!!!:\(err)") // ?????? ????????? ?????????????????? ?????????.
                    }
                    return .empty
                }
        case .refreshLikeData(let index, let isLike):
            let refreshResult = self.refreshArchivesForIsLike(index: index, isLike: isLike)
            switch refreshResult {
            case .success(let newArchives):
                return .just(.setArchives(newArchives))
            case .failure(_):
                break // ?????? ????????? ?????????????????? ?????????.
            }
            return .empty()
        case .showDetail(let index):
            return Observable.concat([
                Observable.just(Mutation.setIsLoading(true)),
                Observable.just(.clearDetailArchive),
                getDetailArchiveInfo(index: index).map { [weak self] result in
                    switch result {
                    case .success(let detailData):
                        self?.currentDetailInnerIndex = 0
                        self?.currentDetailIndex = index
                        self?.steps.accept(ArchiveStep.communityDetailIsRequired(
                            data: detailData,
                            currentIndex: 0,
                            reactor: self ?? CommunityReactor(repository: CommunityRepositoryImplement(),
                                                              bannerRepository: BannerRepositoryImplement(),
                                                              likeRepository: LikeRepositoryImplement(),
                                                              detailRepository: DetailRepositoryImplement())))
                    case .failure(let err):
                        self?.err.onNext(err)
                    }
                    return .empty
                },
                Observable.just(Mutation.setIsLoading(false))
            ])
        case .spreadDetailData(let infoData, let index):
            self.currentDetailIndex = index
            self.currentDetailInnerIndex = 0
            return Observable.from([
                .setDetailArchive(DetailInfo(archiveInfo: infoData, index: self.currentDetailInnerIndex)),
                .setCurrentDetailUserImage(self.currentState.archives.value[index].authorProfileImage),
                .setCurrentDetailUserImage(self.currentState.archives.value[index].authorNickname),
                .setDetailsIsLike(self.currentState.archives.value[index].isLiked)
            ])
        case .showNextPage:
            if let photoImageData = self.currentState.detailArchive.archiveInfo.images { // ?????? ???????????? ?????????
                if photoImageData.count + 1 <= self.currentDetailInnerIndex + 1 { // ????????? ??????, ?????? ???????????? ????????????.
                    return getNextUserDetail()
                } else {
                    self.currentDetailInnerIndex += 1
                    return .just(.setDetailArchive(DetailInfo(archiveInfo: self.currentState.detailArchive.archiveInfo,
                                                              index: self.currentDetailInnerIndex)))
                }
            } else { // ?????? ???????????? ?????????
                // ?????? ???????????? ???????????????.
                return getNextUserDetail()
            }
        case .showBeforePage:
            if self.currentDetailInnerIndex == 0 {
                if self.currentDetailIndex == 0 {
                    return .empty() // ?????? ??? ?????? ????????? ????????? ?????????????????? ???????????? ?????? ?????????.
                } else { // ?????????????????? ????????????.
                    return getBeforeUserDetail()
                }
            } else {
                self.currentDetailInnerIndex -= 1
                return .just(.setDetailArchive(DetailInfo(archiveInfo: self.currentState.detailArchive.archiveInfo,
                                                          index: self.currentDetailInnerIndex)))
            }
        case .showNextUser:
            return getNextUserDetail()
        case .showBeforeUser:
            return getBeforeUserDetail()
        case .getBannerInfo:
            return self.getBannerInfo()
                .map { result in
                    switch result {
                    case .success(let info):
                        return .setBannerInfo(info)
                    case .failure(let err):
                        print("?????? ???????????? ??????: \(err)")
                        return .empty
                    }
                }
        case .bannerClicked(let index):
            let item = self.currentState.bannerInfo[index]
            guard let urlStr = item.mainContentUrl else { return .empty() }
            guard let url = URL(string: urlStr) else { return .empty() }
            switch item.type {
            case .url:
                self.steps.accept(ArchiveStep.bannerUrlIsRequired(url: url))
            case .image:
                self.steps.accept(ArchiveStep.bannerImageIsRequired(imageUrl: url))
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
            newState.archives.value = archives
        case .setDetailArchive(let data):
            newState.detailArchive = data
        case .clearDetailArchive:
            newState.detailArchive = DetailInfo(archiveInfo: .init(archiveId: 0, authorId: 0, name: "", watchedOn: "", emotion: .fun, companions: nil, mainImage: "", images: nil), index: 0)
        case .setCurrentDetailUserImage(let image):
            newState.currentDetailUserImage = image
        case .setCurrentDetailUserNickName(let nickName):
            newState.currentDetailUserNickName = nickName
        case .setDetailsIsLike(let isLike):
            newState.detailIsLike = isLike
        case .setBannerInfo(let info):
            newState.bannerInfo = info
        case .appendArchives(let archives):
            newState.archives.value = state.archives.value + archives
        }
        return newState
    }
    
    // MARK: private function
    
    private func getFirstPublicArchives(sortBy: ArchiveSortType, emotion: Emotion?) -> Observable<Result<[PublicArchive], ArchiveError>> {
        return self.usecase.getFirstPublicArchives(sortBy: sortBy, emotion: emotion)
    }
    
    private func getMorePublicArchives() -> Observable<Result<[PublicArchive], ArchiveError>> {
        return self.usecase.getMorePublicArchives()
    }
    
    private func like(archiveId: Int) -> Observable<Result<Void, ArchiveError>> {
        return self.likeUsecase.like(archiveId: archiveId)
    }
    
    private func unlike(archiveId: Int) -> Observable<Result<Void, ArchiveError>> {
        return self.likeUsecase.unlike(archiveId: archiveId)
    }
    
    private func refreshArchivesForIsLike(index: Int, isLike: Bool) -> Result<[PublicArchive], ArchiveError> {
        var returnValue = self.currentState.archives
        if self.currentState.archives.value.count >= index + 1 {
            returnValue.value[index].isLiked = isLike
            return .success(returnValue.value)
        } else {
            return .failure(.init(.publicArchiveIsRefreshed))
        }
    }
    
    private func getDetailArchiveInfo(index: Int) -> Observable<Result<ArchiveDetailInfo, ArchiveError>> {
        if self.currentState.archives.value.count >= index + 1 {
            return self.detailUsecase.getDetailArchiveInfo(id: "\(self.currentState.archives.value[index].archiveId)")
        } else {
            return .just(.failure(.init(.publicArchiveIsRefreshed)))
        }
    }
    
    private func getBeforeUserDetail() -> Observable<Mutation> {
        if self.currentDetailIndex == 0 {
            return .empty()
        } else {
            return Observable.concat([
                Observable.just(Mutation.setIsShimmerLoading(true)),
                getDetailArchiveInfo(index: self.currentDetailIndex - 1).map { [weak self] result in
                    switch result {
                    case .success(let detailData):
                        self?.action.onNext(.spreadDetailData(infoData: detailData,
                                                              index: (self?.currentDetailIndex ?? 0) - 1))
                    case .failure(let err):
                        self?.err.onNext(err)
                    }
                    return .empty
                },
                Observable.just(Mutation.setIsShimmerLoading(false))
            ])
        }
    }
    
    private func getNextUserDetail() -> Observable<Mutation> {
        ImageCache.default.clearCache()
        if self.currentDetailIndex + 1 >= self.currentState.archives.value.count { // ???????????? ???????????? ????????? ??? ?????????????????? ??????????????????. ????????? ????????????.
            return self.getMorePublicArchives()
                .map { result -> Result<[PublicArchive], ArchiveError> in
                    switch result {
                    case .success(let archives):
                        return .success(archives)
                    case .failure(let err):
                        return .failure(err)
                    }
                }
                .flatMap { [weak self] result -> Observable<Mutation> in
                    switch result {
                    case .success(let archives):
                        if archives.count > 0 {
                            return Observable.concat([
                                Observable.just(.appendArchives(archives)),
                                self?.detailUsecase.getDetailArchiveInfo(id: "\(archives[0].archiveId)")
                                    .map { result in
                                        switch result {
                                        case .success(let detailData):
                                            self?.action.onNext(.spreadDetailData(infoData: detailData,
                                                                                  index: (self?.currentDetailIndex ?? 0) + 1))
                                        case .failure(let err):
                                            self?.err.onNext(err)
                                        }
                                        return .empty
                                    } ?? Observable.just(.empty)
                            ])
                        } else { // ???????????? ???????????? ???????????? [] ??? ??????
                            return .empty()
                        }
                    case .failure(let err):
                        self?.err.onNext(err)
                        return .just(.empty)
                    }
                }
        } else { // ?????? ?????? ????????? ????????????
            return Observable.concat([
                Observable.just(Mutation.setIsShimmerLoading(true)),
                getDetailArchiveInfo(index: self.currentDetailIndex + 1).map { [weak self] result in
                    switch result {
                    case .success(let detailData):
                        self?.action.onNext(.spreadDetailData(infoData: detailData,
                                                              index: (self?.currentDetailIndex ?? 0) + 1))
                    case .failure(let err):
                        self?.err.onNext(err)
                    }
                    return .empty
                },
                Observable.just(Mutation.setIsShimmerLoading(false))
            ])
        }
    }
    
    private func getBannerInfo() -> Observable<Result<[BannerInfo], ArchiveError>> {
        return self.bannerUsecase.getBanner()
    }
    
    // MARK: internal function
    
    func runReturnEndFlow() {
        self.action.onNext(.endFlow)
    }
    
}

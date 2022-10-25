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
        let innerIndex: Int
    }
    
    // MARK: private property
    
    private let usecase: CommunityUsecase
    private let bannerUsecase: BannerUsecase
    private let likeUsecase: LikeUsecase
    private let detailUsecase: DetailUsecase
    private let reportUsecase: ReportUsecase
    private var archiveSortType: ArchiveSortType = .sortByRegist
    private var filterEmotion: Emotion?
    
    private(set) var currentDetailIndex: Int = 0
    private var currentDetailInnerIndex: Int = 0
    
    // MARK: internal property
    
    let steps = PublishRelay<Step>()
    let initialState = State()
    var err: PublishSubject<ArchiveError> = .init()
    
    // MARK: lifeCycle
    
    init(repository: CommunityRepository,
         bannerRepository: BannerRepository,
         likeRepository: LikeRepository,
         detailRepository: DetailRepository,
         reportRepository: ReportRepository) {
        self.usecase = CommunityUsecase(repository: repository)
        self.bannerUsecase = BannerUsecase(repository: bannerRepository)
        self.likeUsecase = LikeUsecase(repository: likeRepository)
        self.detailUsecase = DetailUsecase(repository: detailRepository)
        self.reportUsecase = ReportUsecase(repository: reportRepository)
    }
    
    enum Action {
        case endFlow
        case getFirstPublicArchives(sortBy: ArchiveSortType, emotion: Emotion?)
        case getMorePublicArchives
        case refreshPublicArchives
        case showDetail(index: Int)
        case spreadDetailData(infoData: ArchiveDetailInfo, index: Int)
        case showNextPage
        case showBeforePage
        case showNextUser
        case showBeforeUser
        case getBannerInfo
        case bannerClicked(index: Int)
        case showReportPage
        case report(archiveId: Int, reason: ReportReason)
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
        case setBannerInfo([BannerInfo])
        case appendArchives([PublicArchive])
    }
    
    struct State {
        var isLoading: Bool = false
        var isShimmerLoading: Bool = false
        var archives: Pulse<[PublicArchive]> = Pulse(wrappedValue: [])
        var detailArchive: DetailInfo = DetailInfo(
            archiveInfo: .init(archiveId: 0, authorId: 0, name: "", watchedOn: "", emotion: .fun, companions: nil, mainImage: "", images: nil),
            innerIndex: 0)
        var currentDetailUserNickName: String = ""
        var currentDetailUserImage: String = ""
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
                                                              detailRepository: DetailRepositoryImplement(),
                                                              reportRepository: ReportRepositoryImplement())))
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
                .setDetailArchive(DetailInfo(archiveInfo: infoData, innerIndex: self.currentDetailInnerIndex)),
                .setCurrentDetailUserImage(self.currentState.archives.value[index].authorProfileImage),
                .setCurrentDetailUserImage(self.currentState.archives.value[index].authorNickname)
            ])
        case .showNextPage:
            if let photoImageData = self.currentState.detailArchive.archiveInfo.images { // 포토 데이터가 있으면
                if photoImageData.count + 1 <= self.currentDetailInnerIndex + 1 { // 인덱스 초과, 다음 데이터로 넘어간다.
                    return getNextUserDetail()
                } else {
                    self.currentDetailInnerIndex += 1
                    return .just(.setDetailArchive(DetailInfo(archiveInfo: self.currentState.detailArchive.archiveInfo,
                                                              innerIndex: self.currentDetailInnerIndex)))
                }
            } else { // 포토 데이터가 없다면
                // 다음 데이터로 넘어가본다.
                return getNextUserDetail()
            }
        case .showBeforePage:
            if self.currentDetailInnerIndex == 0 {
                if self.currentDetailIndex == 0 {
                    return .empty() // 현재 첫 번째 사진의 첫번째 인덱스인경우 아무것도 하지 않는다.
                } else { // 이전데이터로 넘어간다.
                    return getBeforeUserDetail()
                }
            } else {
                self.currentDetailInnerIndex -= 1
                return .just(.setDetailArchive(DetailInfo(archiveInfo: self.currentState.detailArchive.archiveInfo,
                                                          innerIndex: self.currentDetailInnerIndex)))
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
                        print("배너 불러오기 오류: \(err)")
                        return .empty
                    }
                }
        case .bannerClicked(let index):
            let item = self.currentState.bannerInfo[index]
            guard let urlStr = item.mainContentUrl else { return .empty() }
            guard let url = URL(string: urlStr) else { return .empty() }
            switch item.type {
            case .url:
                self.steps.accept(ArchiveStep.openUrlIsRequired(url: url, title: ""))
            case .image:
                self.steps.accept(ArchiveStep.bannerImageIsRequired(imageUrl: url))
            }
            return .empty()
        case .showReportPage:
            self.steps.accept(ArchiveStep.communityReportIsRequired(reactor: self))
            return .empty()
        case .report(let archiveId, let reason):
            return Observable.concat([
                Observable.just(Mutation.setIsLoading(true)),
                self.report(archiveId: archiveId, reason: reason.localizaedValue)
                    .map { [weak self] result in
                        switch result {
                        case .success(_):
                            break
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
        case .setIsShimmerLoading(let isLoading):
            newState.isShimmerLoading = isLoading
        case .setArchives(let archives):
            newState.archives.value = archives
        case .setDetailArchive(let data):
            newState.detailArchive = data
        case .clearDetailArchive:
            newState.detailArchive = DetailInfo(archiveInfo: .init(archiveId: 0, authorId: 0, name: "", watchedOn: "", emotion: .fun, companions: nil, mainImage: "", images: nil), innerIndex: 0)
        case .setCurrentDetailUserImage(let image):
            newState.currentDetailUserImage = image
        case .setCurrentDetailUserNickName(let nickName):
            newState.currentDetailUserNickName = nickName
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
        if self.currentDetailIndex + 1 >= self.currentState.archives.value.count { // 아카이브 데이터가 끝나서 또 다음페이지를 받아줘야한다. 그리고 뿌려주자.
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
                        } else { // 새로받은 아카이브 데이터가 [] 인 경우
                            return .empty()
                        }
                    case .failure(let err):
                        self?.err.onNext(err)
                        return .just(.empty)
                    }
                }
        } else { // 다음 유저 데이터 가져오기
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
    
    private func report(archiveId: Int, reason: String) -> Observable<Result<Void, ArchiveError>> {
        return self.reportUsecase.report(archiveId: archiveId, reason: reason)
    }
    
    // MARK: internal function
    
    func runReturnEndFlow() {
        self.action.onNext(.endFlow)
    }
    
}

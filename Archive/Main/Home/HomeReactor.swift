//
//  HomeReactor.swift
//  Archive
//
//  Created by TTOzzi on 2021/11/13.
//

import ReactorKit
import RxRelay
import RxFlow
import SwiftyJSON
import Moya
import Foundation

final class HomeReactor: Reactor, Stepper, MainTabStepperProtocol {
    
    // MARK: private property
    
    private let usecase: MyArchiveUsecase
    private let detailUsecase: DetailUsecase
    
    // MARK: internal property
    
    let steps = PublishRelay<Step>()
    let initialState: State = State()
    let err: PublishSubject<ArchiveError> = .init()
    let willDeleteLastArchive: PublishSubject<Void> = .init()
    
    // MARK: lifeCycle
    
    init(myArchiveRepository: MyArchiveRepository, detailRepository: DetailRepository) {
        self.usecase = MyArchiveUsecase(repository: myArchiveRepository)
        self.detailUsecase = DetailUsecase(repository: detailRepository)
    }
    
    enum Action {
        case endFlow
        case getMyArchives(sortType: ArchiveSortType, emotion: Emotion?)
        case showDetail(Int)
        case refreshMyArchives
        case moreMyArchives
        case deletedArchived(archiveId: String)
    }
    
    enum Mutation {
        case empty
        case setIsLoading(Bool)
        case setIsShimmering(Bool)
        case setArchives([ArchiveInfo])
        case setCurrentArchiveTimeSortBy(ArchiveSortType)
        case setCurrentArchiveEmotionSortBy(Emotion?)
        case setArvhivesCount(Int)
        case appendArchives([ArchiveInfo])
        case deleteArchive(archiveId: String)
    }
    
    struct State {
        var archives: [ArchiveInfo] = [ArchiveInfo]()
        var isLoading: Bool = false
        var isShimmering: Bool = false
        var arvhivesCount: Int = 0
        var currentArchiveTimeSortBy: ArchiveSortType = .sortByRegist
        var currentArchiveEmotionSortBy: Emotion?
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .endFlow:
            self.steps.accept(ArchiveStep.homeIsComplete)
            return .empty()
        case .getMyArchives(let sortType, let emotion):
            return Observable.concat([
                Observable.just(.setIsShimmering(true)),
                self.getFirstArchives(sortBy: sortType, emotion: emotion).map { result -> Result<ArchiveInfoFull, ArchiveError> in
                    switch result {
                    case .success(let info):
                        return .success(info)
                    case .failure(let err):
                        return .failure(err)
                    }
                }.flatMap { [weak self] result -> Observable<Mutation> in
                    switch result {
                    case .success(let info):
                        return .from([.setArchives(info.archiveInfoList),
                                      .setArvhivesCount(info.totalCount),
                                      .setCurrentArchiveTimeSortBy(sortType),
                                      .setCurrentArchiveEmotionSortBy(emotion)
                        ])
                    case .failure(let err):
                        print("err: \(err)")
                        // 이거 실패하면 로그아웃 처리하자 그냥... 그게 젤 안전할듯.. 안그러면 앱 지웠다 깔아야함
                        LogInManager.shared.logOut()
                        self?.steps.accept(ArchiveStep.logout)
                        return .empty()
                    }
                },
                Observable.just(.setIsShimmering(false))
            ])
        case .moreMyArchives:
            if !usecase.isQuerying && !usecase.isEndOfPage {
                return Observable.concat([
                    Observable.just(.setIsLoading(true)),
                    getMoreArchives().map { [weak self] result in
                        switch result {
                        case .success(let archives):
                            return .appendArchives(archives)
                        case .failure(let err):
                            self?.err.onNext(err)
                            return .empty
                        }
                    },
                    Observable.just(.setIsLoading(false))
                ])
            } else {
                return .empty()
            }
        case .refreshMyArchives:
            return Observable.concat([
                Observable.just(.setIsShimmering(true)),
                self.getFirstArchives(sortBy: self.currentState.currentArchiveTimeSortBy,
                                      emotion: self.currentState.currentArchiveEmotionSortBy).map { result -> Result<ArchiveInfoFull, ArchiveError> in
                                          switch result {
                                          case .success(let info):
                                              return .success(info)
                                          case .failure(let err):
                                              return .failure(err)
                                          }
                                      }.flatMap { [weak self] result -> Observable<Mutation> in
                                          switch result {
                                          case .success(let info):
                                              return .from([.setArchives(info.archiveInfoList),
                                                            .setArvhivesCount(info.totalCount)
                                              ])
                                          case .failure(let err):
                                              self?.err.onNext(err)
                                              return .empty()
                                          }
                                      },
                Observable.just(.setIsShimmering(false))
            ])
        case .showDetail(let index):
            return Observable.concat([
                Observable.just(.setIsLoading(true)),
                self.getDetailArchiveInfo(id: "\(currentState.archives[index].archiveId)").map { [weak self] result in
                    switch result {
                    case .success(let info):
                        self?.steps.accept(ArchiveStep.detailIsRequired(
                            infoData: info,
                            index: index,
                            isPublic: self?.currentState.archives[index].isPublic ?? false)
                        )
                        return .empty
                    case .failure(let err):
                        self?.err.onNext(err)
                        return .empty
                    }
                },
                Observable.just(.setIsLoading(false))
            ])
        case .deletedArchived(let archiveId):
            return .just(.deleteArchive(archiveId: archiveId))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .empty:
            break
        case .setIsShimmering(let isShimmering):
            newState.isShimmering = isShimmering
        case .setIsLoading(let isLoading):
            newState.isLoading = isLoading
        case .setArchives(let archives):
            newState.archives = archives
        case .setCurrentArchiveTimeSortBy(let type):
            newState.currentArchiveTimeSortBy = type
        case .setCurrentArchiveEmotionSortBy(let emotion):
            newState.currentArchiveEmotionSortBy = emotion
        case .setArvhivesCount(let count):
            newState.arvhivesCount = count
        case .appendArchives(let archives):
            newState.archives = state.archives + archives
        case .deleteArchive(let archiveId):
            if let willDeletedArchiveIdInt = Int(archiveId) {
                if state.archives.last?.archiveId == willDeletedArchiveIdInt {
                    self.willDeleteLastArchive.onNext(())
                }
            }
            newState.archives = state.archives.filter({ "\($0.archiveId)" != archiveId })
            newState.arvhivesCount = state.arvhivesCount - 1
        }
        return newState
    }
    
    // MARK: private function
    
    private func getFirstArchives(sortBy: ArchiveSortType, emotion: Emotion?) -> Observable<Result<ArchiveInfoFull, ArchiveError>> {
        return self.usecase.getFirstArchives(sortBy: sortBy,
                                             emotion: emotion)
    }
    
    private func getMoreArchives() -> Observable<Result<[ArchiveInfo], ArchiveError>> {
        return self.usecase.getMoreArchives()
    }
    
    private func getDetailArchiveInfo(id: String) -> Observable<Result<ArchiveDetailInfo, ArchiveError>> {
        return self.detailUsecase.getDetailArchiveInfo(id: id)
    }
    
    private func stringDateToDate(_ str: String) -> Date {
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "yy/MM/dd"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.date(from: str) ?? Date()
    }
    
    // MARK: internal function
    
    func runReturnEndFlow() {
        self.action.onNext(.endFlow)
    }
    
}

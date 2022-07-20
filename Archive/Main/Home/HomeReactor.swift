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
    
    // MARK: internal property
    
    let steps = PublishRelay<Step>()
    let initialState: State = State()
    
    // MARK: lifeCycle
    
    init(myArchiveRepository: MyArchiveRepository) {
        self.usecase = MyArchiveUsecase(repository: myArchiveRepository)
    }
    
    enum Action {
        case endFlow
        case getMyArchives(sortType: ArchiveSortType, emotion: Emotion?)
        case showDetail(Int)
        case refreshMyArchives
    }
    
    enum Mutation {
        case empty
        case setIsLoading(Bool)
        case setIsShimmering(Bool)
        case setArchives([ArchiveInfo])
        case setCurrentArchiveTimeSortBy(ArchiveSortType)
        case setCurrentArchiveEmotionSortBy(Emotion?)
        case setArvhivesCount(Int)
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
                self.getArchives(sortBy: sortType, emotion: emotion).map { result -> Result<ArchiveInfoFull, ArchiveError> in
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
        case .refreshMyArchives:
            return Observable.concat([
                Observable.just(.setIsShimmering(true)),
                self.getArchives(sortBy: self.currentState.currentArchiveTimeSortBy,
                                 emotion: self.currentState.currentArchiveEmotionSortBy).map { result -> Result<ArchiveInfoFull, ArchiveError> in
                    switch result {
                    case .success(let info):
                        return .success(info)
                    case .failure(let err):
                        return .failure(err)
                    }
                }.flatMap { result -> Observable<Mutation> in
                    switch result {
                    case .success(let info):
                        return .from([.setArchives(info.archiveInfoList),
                                      .setArvhivesCount(info.totalCount)
                                     ])
                    case .failure(let err):
                        print("err: \(err)")
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
                    case .success(let data):
                        self?.moveToDetail(data: data, index: index)
                    case .failure(let err):
                        print("err: \(err.localizedDescription)")
                    }
                    return .setIsLoading(false)
                }
            ])
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
        }
        return newState
    }
    
    // MARK: private function
    
    private func getArchives(sortBy: ArchiveSortType, emotion: Emotion?) -> Observable<Result<ArchiveInfoFull, ArchiveError>> {
        return self.usecase.getArchives(sortBy: sortBy,
                                        emotion: emotion)
    }
    
    private func getDetailArchiveInfo(id: String) -> Observable<Result<Data, Error>> {
        let provider = ArchiveProvider.shared.provider
        return provider.rx.request(.getDetailArchive(archiveId: id), callbackQueue: DispatchQueue.global())
            .asObservable()
            .map { result in
                return .success(result.data)
            }
            .catch { err in
                return .just(.failure(err))
            }
    }
    
    private func convertDataToArchivesInfos(data: Data) -> ([ArchiveInfo], Int) {
        var items: [ArchiveInfo] = [ArchiveInfo]()
        var itemsCount = 0
        if let jsonData: JSON = try? JSON.init(data: data) {
            itemsCount = jsonData["archiveCount"].intValue
            let archivesJson = jsonData["archives"]
            for item in archivesJson {
                if let itemData = try? item.1.rawData() {
                    if let info = ArchiveInfo.fromJson(jsonData: itemData) {
                        items.append(info)
                    }
                }
            }
        }
        return (items, itemsCount)
    }
    
    private func moveToDetail(data: Data, index: Int) {
        if let info = ArchiveDetailInfo.fromJson(jsonData: data) {
            DispatchQueue.main.async { [weak self] in
                self?.steps.accept(ArchiveStep.detailIsRequired(info, index))
            }
        }
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

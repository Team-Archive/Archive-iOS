//
//  MyArchiveUsecase.swift
//  Archive
//
//  Created by hanwe on 2022/07/16.
//

import RxSwift

class MyArchiveUsecase: NSObject {
    
    // MARK: private property
    
    private let repository: MyArchiveRepository
    private var lastSeenArchiveDateMilli: Int?
    private var lastSeenArchiveId: Int?
    
    // MARK: internal property
    
    private(set) var isEndOfPage: Bool = false
    private(set) var isQuerying: Bool = false
    private(set) var currentEmotion: Emotion?
    private(set) var currentSortBy: ArchiveSortType = .sortByRegist
    
    // MARK: lifeCycle
    
    init(repository: MyArchiveRepository) {
        self.repository = repository
    }
    
    // MARK: private function
    
    private func getArchives(lastSeenArchiveDateMilli: Int?, lastSeenArchiveId: Int?) -> Observable<Result<ArchiveInfoFull, ArchiveError>> {
        self.isQuerying = true
        return self.repository.getArchives(sortBy: self.currentSortBy,
                                           emotion: self.currentEmotion,
                                           lastSeenArchiveDateMilli: lastSeenArchiveDateMilli,
                                           lastSeenArchiveId: lastSeenArchiveId)
        .flatMap { [weak self] result -> Observable<Result<ArchiveInfoFull, ArchiveError>> in
            switch result {
            case .success(let archivesFullData):
                if archivesFullData.archiveInfoList.count == 0 {
                    self?.isEndOfPage = true
                } else {
                    self?.isEndOfPage = false
                    self?.lastSeenArchiveDateMilli = archivesFullData.archiveInfoList.last?.dateMilli
                    self?.lastSeenArchiveId = archivesFullData.archiveInfoList.last?.archiveId
                }
                self?.isQuerying = false
                return .just(.success(archivesFullData))
            case .failure(let err):
                self?.isQuerying = false
                return .just(.failure(err))
            }
        }
    }
    
    // MARK: internal function
    
    func getFirstArchives(sortBy: ArchiveSortType, emotion: Emotion?) -> Observable<Result<ArchiveInfoFull, ArchiveError>> {
        self.currentSortBy = sortBy
        self.currentEmotion = emotion
        self.lastSeenArchiveDateMilli = nil
        self.lastSeenArchiveId = nil
        self.isEndOfPage = false
        self.isQuerying = false
        return self.getArchives(lastSeenArchiveDateMilli: self.lastSeenArchiveDateMilli,
                                lastSeenArchiveId: self.lastSeenArchiveId)
    }
    
    func getMoreArchives() -> Observable<Result<[ArchiveInfo], ArchiveError>> {
        return self.getArchives(lastSeenArchiveDateMilli: self.lastSeenArchiveDateMilli,
                                lastSeenArchiveId: self.lastSeenArchiveId).map { result in
            switch result {
            case .success(let info):
                return .success(info.archiveInfoList)
            case .failure(let err):
                return .failure(err)
            }
            
        }
    }
    
}

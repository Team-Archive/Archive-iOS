//
//  CommunityUsecase.swift
//  Archive
//
//  Created by hanwe on 2022/06/25.
//

import RxSwift

class CommunityUsecase: NSObject {
    
    // MARK: private property
    
    private let repository: CommunityRepository
    private var lastSeenArchiveDateMilli: Int?
    private var lastSeenArchiveId: Int?
    
    // MARK: internal property
    
    private(set) var isEndOfPage: Bool = false
    private(set) var isQuerying: Bool = false
    private(set) var currentEmotion: Emotion?
    private(set) var currentSortBy: ArchiveSortType = .sortByRegist
    
    // MARK: lifeCycle
    
    init(repository: CommunityRepository) {
        self.repository = repository
    }
    
    // MARK: private function
    
    private func getPublicArchives(lastSeenArchiveDateMilli: Int?, lastSeenArchiveId: Int?) -> Observable<Result<[PublicArchive], ArchiveError>> {
        self.isQuerying = true
        return self.repository.getPublicArchives(sortBy: self.currentSortBy,
                                                 emotion: self.currentEmotion,
                                                 lastSeenArchiveDateMilli: lastSeenArchiveDateMilli,
                                                 lastSeenArchiveId: lastSeenArchiveId)
        .flatMap { [weak self] result -> Observable<Result<[PublicArchive], ArchiveError>> in
            switch result {
            case .success(let archives):
                if archives.count == 0 {
                    self?.isEndOfPage = true
                } else {
                    self?.isEndOfPage = false
                    self?.lastSeenArchiveDateMilli = archives.last?.dateMilli
                    self?.lastSeenArchiveId = archives.last?.archiveId
                }
                self?.isQuerying = false
                return .just(.success(archives))
            case .failure(let err):
                self?.isQuerying = false
                return .just(.failure(err))
            }
        }
    }
    
    // MARK: internal function
    
    func getFirstPublicArchives(sortBy: ArchiveSortType, emotion: Emotion?) -> Observable<Result<[PublicArchive], ArchiveError>> {
        self.currentSortBy = sortBy
        self.currentEmotion = emotion
        self.lastSeenArchiveDateMilli = nil
        self.lastSeenArchiveId = nil
        self.isEndOfPage = false
        self.isQuerying = false
        return self.getPublicArchives(lastSeenArchiveDateMilli: self.lastSeenArchiveDateMilli, lastSeenArchiveId: self.lastSeenArchiveId)
    }
    
    func getMorePublicArchives() -> Observable<Result<[PublicArchive], ArchiveError>> {
        return self.getPublicArchives(lastSeenArchiveDateMilli: self.lastSeenArchiveDateMilli,
                                      lastSeenArchiveId: self.lastSeenArchiveId)
    }
    
}

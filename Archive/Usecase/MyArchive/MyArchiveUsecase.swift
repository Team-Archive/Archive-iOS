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
    private var currentEmotion: Emotion?
    private var currentSortBy: ArchiveSortType?
    private var lastSeenArchiveDateMilli: Int = 0
    private var lastSeenArchiveId: Int = 0
    private var isEndOfPage: Bool = false
    
    // MARK: internal property
    
    // MARK: lifeCycle
    
    init(repository: MyArchiveRepository) {
        self.repository = repository
    }
    
    // MARK: private function
    
    private func setLastInfo(lastSeenArchiveDateMilli: Int, lastSeenArchiveId: Int) {
        self.lastSeenArchiveId = lastSeenArchiveId
        self.lastSeenArchiveDateMilli = lastSeenArchiveDateMilli
    }
    
    // MARK: internal function
    
    func getArchives(sortBy: ArchiveSortType, emotion: Emotion?) -> Observable<Result<[ArchiveInfo], ArchiveError>> { // 호출할때마다 조건이 변하지 않으면 페이징처리된 데이터가 내려온다.
        if sortBy == self.currentSortBy && emotion == self.currentEmotion {
            if self.isEndOfPage { // 페이지의 끝이면
                return .just(.failure(.init(.publicArchiveIsEndOfPage)))
            } else {
                return self.repository.getArchives(sortBy: sortBy,
                                                         emotion: emotion,
                                                         lastSeenArchiveDateMilli: self.lastSeenArchiveDateMilli,
                                                         lastSeenArchiveId: self.lastSeenArchiveId)
                .flatMap { [weak self] result -> Observable<Result<[ArchiveInfo], ArchiveError>> in
                    switch result {
                    case .success(let archives):
                        if archives.count == 0 {
                            self?.isEndOfPage = true
                        } else {
                            self?.isEndOfPage = false
                        }
                        self?.setLastInfo(lastSeenArchiveDateMilli: archives.last?.dateMilli ?? 0,
                                          lastSeenArchiveId: archives.last?.archiveId ?? 0)
                        return .just(.success(archives))
                    case .failure(let err):
                        return .just(.failure(err))
                    }
                }
            }
        } else {
            self.currentSortBy = sortBy
            self.currentEmotion = emotion
            return self.repository.getArchives(sortBy: sortBy,
                                                     emotion: emotion,
                                                     lastSeenArchiveDateMilli: nil,
                                                     lastSeenArchiveId: nil)
            .flatMap { [weak self] result -> Observable<Result<[ArchiveInfo], ArchiveError>> in
                switch result {
                case .success(let archives):
                    if archives.count == 0 {
                        self?.isEndOfPage = true
                    } else {
                        self?.isEndOfPage = false
                    }
                    self?.setLastInfo(lastSeenArchiveDateMilli: archives.last?.dateMilli ?? 0,
                                              lastSeenArchiveId: archives.last?.archiveId ?? 0)
                    return .just(.success(archives))
                case .failure(let err):
                    return .just(.failure(err))
                }
            }
        }
    }
    
}

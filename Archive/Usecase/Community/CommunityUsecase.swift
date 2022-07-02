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
    private var currentEmotion: Emotion?
    private var currentSortBy: PublicArchiveSortBy?
    private var lastSeenArchiveDateMilli: Int = 0
    private var lastSeenArchiveId: Int = 0
    
    // MARK: internal property
    
    // MARK: lifeCycle
    
    init(repository: CommunityRepository) {
        self.repository = repository
    }
    
    // MARK: private function
    
    // MARK: internal function
    
    func getPublicArchives(sortBy: PublicArchiveSortBy, emotion: Emotion?) -> Observable<Result<[PublicArchive], ArchiveError>> { // 호출할때마다 조건이 변하지 않으면 페이징처리된 데이터가 내려온다.
        if sortBy == self.currentSortBy && emotion == self.currentEmotion {
            return self.repository.getPublicArchives(sortBy: sortBy,
                                                     emotion: emotion,
                                                     lastSeenArchiveDateMilli: self.lastSeenArchiveDateMilli,
                                                     lastSeenArchiveId: self.lastSeenArchiveId)
        } else {
            self.currentSortBy = sortBy
            self.currentEmotion = emotion
            return self.repository.getPublicArchives(sortBy: sortBy,
                                                     emotion: emotion,
                                                     lastSeenArchiveDateMilli: nil,
                                                     lastSeenArchiveId: nil)
        }
    }
    
    func setLastInfo(lastSeenArchiveDateMilli: Int, lastSeenArchiveId: Int) {
        self.lastSeenArchiveId = lastSeenArchiveId
        self.lastSeenArchiveDateMilli = lastSeenArchiveDateMilli
    }
    
}

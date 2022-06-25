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
    
    // MARK: internal property
    
    // MARK: lifeCycle
    
    init(repository: CommunityRepository) {
        self.repository = repository
    }
    
    // MARK: private function
    
    // MARK: internal function
    func getPublicArchives(sortBy: PublicArchiveSortBy, emotion: Emotion?) -> Observable<Result<[PublicArchive], ArchiveError>> {
        return self.repository.getPublicArchives(sortBy: sortBy,
                                                 emotion: nil, // TODO: 작업
                                                 lastSeenArchiveDateMilli: nil, // TODO: 작업
                                                 lastSeenArchiveId: nil) // TODO: 작업
    }
    
}

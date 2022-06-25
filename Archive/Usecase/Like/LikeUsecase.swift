//
//  LikeUsecase.swift
//  Archive
//
//  Created by hanwe on 2022/06/25.
//

import RxSwift

class LikeUsecase: NSObject {
    
    // MARK: private property
    
    private let repository: LikeRepository
    
    // MARK: internal property
    
    // MARK: lifeCycle
    
    init(repository: LikeRepository) {
        self.repository = repository
    }
    
    // MARK: private function
    
    // MARK: internal function
    
    func like(archiveId: Int) -> Observable<Result<Void, ArchiveError>> {
        return self.repository.like(archiveId: archiveId)
    }
    
    func unlike(archiveId: Int) -> Observable<Result<Void, ArchiveError>> {
        return self.repository.unlike(archiveId: archiveId)
    }
    
    // MARK: action

}

//
//  ArchiveEditUsecase.swift
//  Archive
//
//  Created by hanwe on 2022/12/17.
//

import RxSwift

class ArchiveEditUsecase: NSObject {
    
    // MARK: private property
    
    private let repository: ArchiveEditRepository
    
    // MARK: internal property
    
    // MARK: lifeCycle
    
    init(repository: ArchiveEditRepository) {
        self.repository = repository
    }
    
    // MARK: private function
    
    // MARK: internal function
    
    func switchIsPublicArchive(id: Int, isPublic: Bool) -> Observable<Result<Void, ArchiveError>> {
        return self.repository.switchIsPublicArchive(id: id, isPublic: isPublic)
    }

}

//
//  ReportUsecase.swift
//  Archive
//
//  Created by hanwe on 2022/09/12.
//

import RxSwift

class ReportUsecase: NSObject {
    
    // MARK: private property
    
    private let repository: ReportRepository
    
    // MARK: internal property
    
    // MARK: lifeCycle
    
    init(repository: ReportRepository) {
        self.repository = repository
    }
    
    // MARK: private function
    
    // MARK: internal function
    
    func report(archiveId: Int, reason: String) -> Observable<Result<Void, ArchiveError>> {
        return self.repository.report(archiveId: archiveId, reason: reason)
    }

}

//
//  DetailUsecase.swift
//  Archive
//
//  Created by hanwe on 2022/06/26.
//

import RxSwift

class DetailUsecase: NSObject {
    
    // MARK: private property
    
    private let repository: DetailRepository
    
    // MARK: internal property
    
    // MARK: lifeCycle
    
    init(repository: DetailRepository) {
        self.repository = repository
    }
    
    // MARK: private function
    
    // MARK: internal function
    
    func getDetailArchiveInfo(id: String) -> Observable<Result<ArchiveDetailInfo, ArchiveError>> {
        return self.repository.getDetailArchiveInfo(id: id)
    }

}

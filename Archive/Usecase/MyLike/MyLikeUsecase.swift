//
//  MyLikeUsecase.swift
//  Archive
//
//  Created by hanwe on 2022/07/31.
//

import RxSwift

class MyLikeUsecase: NSObject {
    
    // MARK: private property
    
    private let repository: MyLikeRepository
    
    // MARK: internal property
    
    // MARK: lifeCycle
    
    init(repository: MyLikeRepository) {
        self.repository = repository
    }
    
    // MARK: private function
    
    // MARK: internal function
    
    func getMyLikeArchives() -> Observable<Result<[MyLikeArchive], ArchiveError>> {
        return self.repository.getMyLikeArchives()
    }
    
}

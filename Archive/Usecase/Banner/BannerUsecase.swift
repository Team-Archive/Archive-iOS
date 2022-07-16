//
//  BannerUsecase.swift
//  Archive
//
//  Created by hanwe on 2022/07/16.
//

import RxSwift

class BannerUsecase: NSObject {
    
    // MARK: private property
    
    private let repository: BannerRepository
    
    // MARK: internal property
    
    // MARK: lifeCycle
    
    init(repository: BannerRepository) {
        self.repository = repository
    }
    
    // MARK: private function
    
    // MARK: internal function
    
    func getBanner() -> Observable<Result<[BannerInfo], ArchiveError>> {
        return self.repository.getBanner()
    }
    
}

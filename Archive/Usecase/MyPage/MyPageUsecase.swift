//
//  MyPageUsecase.swift
//  Archive
//
//  Created by hanwe on 2022/07/30.
//

import RxSwift

class MyPageUsecase: NSObject {
    
    // MARK: private property
    
    private let repository: MyPageRepository
    
    // MARK: internal property
    
    // MARK: lifeCycle
    
    init(repository: MyPageRepository) {
        self.repository = repository
    }
    
    // MARK: private function
    
    // MARK: internal function
    
    func getCurrentUserInfo() -> Observable<Result<MyLoginInfo, ArchiveError>> {
        return self.repository.getCurrentUserInfo()
    }

}

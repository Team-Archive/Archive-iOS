//
//  LikeUsecase.swift
//  Like
//
//  Created by Hanwe LEE on 2022/08/30.
//

import RxSwift
import Foundation

class LikeUsecase: NSObject {
    
    // MARK: private property
    
    private let repository: LikeRepository
    
    // MARK: property
    
    // MARK: lifeCycle
    
    init(repository: LikeRepository) {
        self.repository = repository
    }
    
    // MARK: private func
    
    // MARK: func
    
    
    func like(idList: [String]) -> Observable<Result<Void, ArchiveError>> {
        return self.repository.like(idList: idList)
    }
    
    func likeCancel(idList: [String]) -> Observable<Result<Void, ArchiveError>> {
        return self.repository.likeCancel(idList: idList)
    }
    
    func getMyLikeIdList() -> Observable<Result<Set<String>, ArchiveError>> {
        return self.repository.getMyLikeIdList()
    }
    
}

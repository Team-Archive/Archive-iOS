//
//  NickNameDuplicationUsecase.swift
//  Archive
//
//  Created by hanwe on 2022/09/24.
//

import RxSwift

class NickNameDuplicationUsecase: NSObject {
    
    // MARK: private property
    
    private let repository: NickNameDuplicationRepository
    
    // MARK: internal property
    
    // MARK: lifeCycle
    
    init(repository: NickNameDuplicationRepository) {
        self.repository = repository
    }
    
    // MARK: private function
    
    // MARK: internal function
    
    func isDuplicatedNickName(_ nickName: String) -> Observable<Result<Bool, ArchiveError>> {
        return self.repository.isDuplicatedNickName(nickName)
    }
    
}

//
//  UpdateProfileUsecase.swift
//  Archive
//
//  Created by hanwe on 2022/09/24.
//

import RxSwift

class UpdateProfileUsecase: NSObject {

    // MARK: private property
    
    private let repository: UpdateProfileRepository
    
    // MARK: internal property
    
    // MARK: lifeCycle
    
    init(repository: UpdateProfileRepository) {
        self.repository = repository
    }
    
    // MARK: private function
    
    // MARK: internal function
    
    func updateProfile(imageData: Data?, nickName: String) -> Observable<Result<Void, ArchiveError>> {
        return .just(.success(()))
    }
    
    
}

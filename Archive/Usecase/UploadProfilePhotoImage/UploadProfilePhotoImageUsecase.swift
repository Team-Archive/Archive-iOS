//
//  UploadProfilePhotoImageUsecase.swift
//  Archive
//
//  Created by hanwe on 2022/11/02.
//

import RxSwift

class UploadProfilePhotoImageUsecase: NSObject {
    
    // MARK: private property
    
    private let repository: UploadProfilePhotoImageRepository
    
    // MARK: internal property
    
    // MARK: lifeCycle
    
    init(repository: UploadProfilePhotoImageRepository) {
        self.repository = repository
    }
    
    // MARK: private function
    
    // MARK: internal function
    
    func uploadImage(_ imageData: Data) -> Observable<Result<Void, ArchiveError>> {
        return self.repository.uploadImage(imageData)
    }
}

//
//  UploadImageUsecase.swift
//  Archive
//
//  Created by hanwe on 2022/08/28.
//

import RxSwift

class UploadImageUsecase: NSObject {
    
    // MARK: private property
    
    private let repository: UploadImageRepository
    
    // MARK: internal property
    
    // MARK: lifeCycle
    
    init(repository: UploadImageRepository) {
        self.repository = repository
    }
    
    // MARK: private function
    
    // MARK: internal function
    
    func uploadImage(_ imageData: Data) -> Observable<Result<String, ArchiveError>> {
        return self.repository.uploadImage(imageData)
    }

}

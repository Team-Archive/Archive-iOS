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
    private let uploadImageRepository: UploadImageRepository
    
    // MARK: internal property
    
    // MARK: lifeCycle
    
    init(repository: UpdateProfileRepository, uploadImageRepository: UploadImageRepository) {
        self.repository = repository
        self.uploadImageRepository = uploadImageRepository
    }
    
    // MARK: private function
    
    private func uploadImage(imageData: Data) -> Observable<Result<String, ArchiveError>> {
        return self.uploadImageRepository.uploadImage(imageData)
    }
    
    // MARK: internal function
    
    func updateProfile(imageData: Data?, nickName: String) -> Observable<Result<Void, ArchiveError>> {
        return .just(.success(()))
    }
    
    
}

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
    private let uploadImageUsecase: UploadImageUsecase
    
    // MARK: internal property
    
    // MARK: lifeCycle
    
    init(repository: UpdateProfileRepository, uploadImageRepository: UploadImageRepository) {
        self.repository = repository
        self.uploadImageUsecase = UploadImageUsecase(repository: uploadImageRepository)
    }
    
    // MARK: private function
    
    private func uploadImage(imageData: Data?) -> Observable<Result<String?, ArchiveError>> {
        guard let data = imageData else { return .just(.success(nil))}
        return self.uploadImageUsecase.uploadImage(data)
            .map { result in
                switch result {
                case .success(let url):
                    return .success(url)
                case .failure(let err):
                    return .failure(err)
                }
            }
    }
    
    // MARK: internal function
    
    func updateProfile(imageData: Data?, nickName: String) -> Observable<Result<UpdateProfileResultData, ArchiveError>> {
        if imageData == nil && nickName == "" { return .just(.failure(.init(.editProfileIsInvaild))) }
        return uploadImage(imageData: imageData)
            .map { result -> Result<String?, ArchiveError> in
                switch result {
                case .success(let imageUrl):
                    return .success(imageUrl)
                case .failure(let err):
                    return .failure(err)
                }
            }
            .flatMap { [weak self] result -> Observable<Result<UpdateProfileResultData, ArchiveError>> in
                switch result {
                case .success(let imageUrl):
                    let optionalNickName: String? = {
                        var returnValue: String?
                        if nickName != "" {
                            returnValue = nickName
                        }
                        return returnValue
                    }()
                    let updateProfileData: UpdateProfileData = UpdateProfileData(imageUrl: imageUrl, nickNmae: optionalNickName)
                    return self?.repository.updateProfile(updataProfileData: updateProfileData) ?? .just(.failure(.init(.selfIsNull)))
                case .failure(let err):
                    return .just(.failure(err))
                }
            }
    }
    
    
}

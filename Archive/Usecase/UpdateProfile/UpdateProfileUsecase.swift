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
    private let uploadImageUsecase: UploadProfilePhotoImageUsecase
    
    private let imageEdit: ImageEdit = ImageEdit()
    
    // MARK: internal property
    
    // MARK: lifeCycle
    
    init(repository: UpdateProfileRepository, uploadImageRepository: UploadProfilePhotoImageRepository) {
        self.repository = repository
        self.uploadImageUsecase = UploadProfilePhotoImageUsecase(repository: uploadImageRepository)
    }
    
    // MARK: private function
    
    private func uploadImage(imageData: Data?) -> Observable<Result<String?, ArchiveError>> {
        guard let imageData = imageData else { return .just(.success(nil))}
        guard let image = UIImage.init(data: imageData) else { return .just(.success(nil)) }
        
        return self.imageEdit.resizeSize(image: image, size: CGSize(width: 300, height: 300))
            .map { result -> Result<Data, ArchiveError> in
                switch result {
                case .success(let resizedImage):
                    guard let resizedImageData: Data = resizedImage.pngData() else { return .failure(.init(.convertImageFail)) }
                    return .success(resizedImageData)
                case .failure(let err):
                    return .failure(err)
                }
            }
            .flatMap { [weak self] result -> Observable<Result<String?, ArchiveError>> in
                switch result {
                case .success(let data):
                    return self?.uploadImageUsecase.uploadImage(data)
                        .map { result in
                            switch result {
                            case .success(let url):
                                return .success(url)
                            case .failure(let err):
                                return .failure(err)
                            }
                        } ?? .just(.failure(.init(.selfIsNull)))
                case .failure(let err):
                    return .just(.failure(err))
                }
            }
    }
    
    // MARK: internal function
    
    func updateProfile(imageData: Data?, nickName: String) -> Observable<Result<ProfileData, ArchiveError>> {
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
            .flatMap { [weak self] result -> Observable<Result<ProfileData, ArchiveError>> in
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

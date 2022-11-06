//
//  UpdateProfileUsecase.swift
//  Archive
//
//  Created by hanwe on 2022/09/24.
//

import RxSwift

class ProfileUsecase: NSObject {

    // MARK: private property
    
    private let repository: ProfileRepository
    private let uploadImageUsecase: UploadProfilePhotoImageUsecase
    
    private let imageEdit: ImageEdit = ImageEdit()
    
    // MARK: internal property
    
    // MARK: lifeCycle
    
    init(repository: ProfileRepository, uploadImageRepository: UploadProfilePhotoImageRepository) {
        self.repository = repository
        self.uploadImageUsecase = UploadProfilePhotoImageUsecase(repository: uploadImageRepository)
    }
    
    // MARK: private function
    
    private func uploadImage(imageData: Data?) -> Observable<Result<Void, ArchiveError>> {
        guard let imageData = imageData else { return .just(.success(()))}
        guard let image = UIImage.init(data: imageData) else { return .just(.failure(.init(.invaldData))) }
        
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
            .flatMap { [weak self] result -> Observable<Result<Void, ArchiveError>> in
                switch result {
                case .success(let data):
                    return self?.uploadImageUsecase.uploadImage(data)
                        .map { result in
                            switch result {
                            case .success(_):
                                return .success(())
                            case .failure(let err):
                                return .failure(err)
                            }
                        } ?? .just(.failure(.init(.selfIsNull)))
                case .failure(let err):
                    return .just(.failure(err))
                }
            }
    }
    
    private func updateNickname(_ newNickname: String?) -> Observable<Result<Void, ArchiveError>> {
        guard let newNickname else { return .just(.success(())) }
        return self.repository.updateNickname(newNickname)
    }
    
    // MARK: internal function
    
    func updateProfile(imageData: Data?, nickName: String?) -> Observable<Result<ProfileData, ArchiveError>> {
        if imageData == nil && nickName == nil { return .just(.failure(.init(.editProfileIsInvaild))) }
        return Observable.zip(uploadImage(imageData: imageData), self.updateNickname(nickName))
            .map { [weak self] resultUploadImage, resultUpdateNickname in
                
                switch resultUploadImage {
                case .success(_):
                    break
                case .failure(let err):
                    return .failure(err)
                }
                
                switch resultUpdateNickname {
                case .success(_):
                    break
                case .failure(let err):
                    return .failure(err)
                }
                
//                return .success(<#T##ProfileData#>)
                return .failure(.init(.invaldData))
            }
    }
    
    
}

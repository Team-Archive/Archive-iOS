//
//  RegistRepositoryImplement.swift
//  Archive
//
//  Created by hanwe on 2022/08/28.
//

import RxSwift

class RegistRepositoryImplement: RegistRepositoty {
    
    // MARK: private property
    
    private let uploadImageUsecase: UploadImageUsecase
    
    // MARK: internal property
    
    init(uploadImageUsecase: UploadImageUsecase) {
        self.uploadImageUsecase = uploadImageUsecase
    }
    
    // MARK: lifeCycle
    
    // MARK: private function
    
    // MARK: internal function
    
    func uploadImages(_ images: [UIImage]) -> Observable<Result<[String], ArchiveError>> {
        let uploadImageObservables: [Observable<Result<String, ArchiveError>>] = {
            var returnValue: [Observable<Result<String, ArchiveError>>] = []
            for image in images {
                let newElement = self.uploadImageUsecase.uploadImage(image)
                returnValue.append(newElement)
            }
            return returnValue
        }()
        return Observable.zip(uploadImageObservables)
            .map { results in
                var returnValue: [String] = []
                for result in results {
                    switch result {
                    case .success(let url):
                        returnValue.append(url)
                    case .failure(let err):
                        return .failure(err)
                    }
                }
                return .success(returnValue)
            }
    }
    
}

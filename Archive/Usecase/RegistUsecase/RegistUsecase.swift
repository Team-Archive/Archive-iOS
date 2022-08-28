//
//  RegistUsecase.swift
//  Archive
//
//  Created by hanwe on 2022/08/28.
//

import UIKit
import RxSwift

class RegistUsecase: NSObject {
    
    // MARK: private property
    
    private let repository: RegistRepositoty
    
    // MARK: internal property
    
    // MARK: lifeCycle
    
    init(repository: RegistRepositoty) {
        self.repository = repository
    }
    
    // MARK: private function
    
    // MARK: internal function
    
    func uploadImages(_ images: [RegistImageInfo]) -> Observable<Result<[UploadImageInfo], ArchiveError>> {
        let realImages: [UIImage] = {
            var returnValue: [UIImage] = []
            for item in images {
                returnValue.append(item.image)
            }
            return returnValue
        }()
        return self.repository.uploadImages(realImages)
            .map { result -> Result<[String], ArchiveError> in
                switch result {
                case .success(let urls):
                    return .success(urls)
                case .failure(let err):
                    return .failure(err)
                }
            }
            .flatMap { result -> Observable<Result<[UploadImageInfo], ArchiveError>> in
                switch result {
                case .success(let urls):
                    if urls.count != images.count {
                        return .just(.failure(.init(.imageUploadCntFail)))
                    }
                    let infoArr: [UploadImageInfo] = {
                        var returnValue: [UploadImageInfo] = []
                        for i in 0..<images.count {
                            let url = urls[i]
                            let color = images[i].color
                            let newElemenet = UploadImageInfo(imageUrl: url, themeColor: color.hexStringFromColor())
                            returnValue.append(newElemenet)
                        }
                        return returnValue
                    }()
                    return .just(.success(infoArr))
                case .failure(let err):
                    return .just(.failure(err))
                }
            }
    }
}

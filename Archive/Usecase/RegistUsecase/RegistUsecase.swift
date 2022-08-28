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
    
    private func uploadImages(_ images: [RegistImageInfo]) -> Observable<Result<[UploadImageInfo], ArchiveError>> {
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
    
    // MARK: internal function
    
    func regist(name: String, watchedOn: String, companions: [String]?, emotion: String, images: [RegistImageInfo], imageContents: [Int: String], isPublic: Bool) -> Observable<Result<Void, ArchiveError>> {
        return self.uploadImages(images)
            .map { result -> Result<[UploadImageInfo], ArchiveError> in
                switch result {
                case .success(let infoArr):
                    return .success(infoArr)
                case .failure(let err):
                    return .failure(err)
                }
            }
            .flatMap { [weak self] result -> Observable<Result<Void, ArchiveError>> in
                switch result {
                case .success(let infoArr):
                    let mainImage = infoArr[0].imageUrl
                    let recordImageDataArr: [RecordImageData]? = {
                        if infoArr.count > 1 {
                            var returnValue: [RecordImageData] = []
                            for i in 1..<infoArr.count {
                                let index = i - 1
                                let review = imageContents[index]
                                let newElement = RecordImageData(image: infoArr[i].imageUrl,
                                                                 review: review ?? "",
                                                                 backgroundColor: infoArr[i].themeColor)
                                returnValue.append(newElement)
                            }
                            return returnValue
                        } else {
                            return []
                        }
                    }()
                    let recordData: RecordData = RecordData(name: name,
                                                            watchedOn: watchedOn,
                                                            companions: companions,
                                                            emotion: emotion,
                                                            mainImage: mainImage,
                                                            images: recordImageDataArr,
                                                            isPublic: isPublic)
                    return self?.repository.regist(info: recordData) ?? .just(.failure(.init(.selfIsNull)))
                case .failure(let err):
                    return .just(.failure(err))
                }
            }
    }
    
    func getThisMonthRegistCnt() -> Observable<Result<Int, ArchiveError>> {
        return self.repository.getThisMonthRegistCnt()
    }
    
    
}

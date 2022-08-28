//
//  RegistRepositoryImplement.swift
//  Archive
//
//  Created by hanwe on 2022/08/28.
//

import RxSwift
import SwiftyJSON

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
    
    func regist(info: RecordData) -> Observable<Result<Void, ArchiveError>> {
        let provider = ArchiveProvider.shared.provider
        return provider.rx.request(.registArchive(info))
            .asObservable()
            .map { result in
                if 200..<300 ~= result.statusCode {
                    return .success(())
                } else {
                    return .failure(.init(from: .server, code: result.statusCode, message: "서버오류"))
                }
            }
            .catch { err in
                return .just(.failure(.init(from: .server, code: err.responseCode, message: err.archiveErrMsg)))
            }
    }
    
}

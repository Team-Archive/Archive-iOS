//
//  UploadImageRepositoryImplement.swift
//  Archive
//
//  Created by hanwe on 2022/08/28.
//

import Moya
import RxSwift
import SwiftyJSON

class UploadImageRepositoryImplement: UploadImageRepository {
    
    func uploadImage(_ image: UIImage) -> Observable<Result<String, ArchiveError>> {
        let provider = ArchiveProvider.shared.provider
        return provider.rx.request(.uploadImage(image))
            .asObservable()
            .map { result in
                if result.statusCode == 200 {
                    guard let resultJson: JSON = try? JSON.init(data: result.data) else { return .failure(.init(.invaldData))}
                    guard let url = resultJson["imageUrl"].string else { return .failure(.init(.imageUploadFail))}
                    return .success(url)
                } else {
                    return .failure(.init(from: .server, code: result.statusCode, message: "서버오류"))
                }
            }
            .catch { err in
                return .just(.failure(.init(from: .server, code: err.responseCode, message: err.archiveErrMsg)))
            }
    }

}

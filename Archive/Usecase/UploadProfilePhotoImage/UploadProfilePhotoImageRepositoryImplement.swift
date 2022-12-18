//
//  UploadProfilePhotoImageRepositoryImplement.swift
//  Archive
//
//  Created by hanwe on 2022/11/02.
//

import Moya
import RxSwift
import SwiftyJSON

class UploadProfilePhotoImageRepositoryImplement: UploadProfilePhotoImageRepository {
    func uploadImage(_ imageData: Data) -> Observable<Result<Void, ArchiveError>> {
        let provider = ArchiveProvider.shared.provider
        return provider.rx.request(.uploadProfilePhotoImage(imageData))
            .asObservable()
            .map { result in
                if 200...299 ~= result.statusCode {
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

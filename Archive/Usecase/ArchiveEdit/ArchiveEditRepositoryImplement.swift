//
//  ArchiveEditRepositoryImplement.swift
//  Archive
//
//  Created by hanwe on 2022/12/17.
//

import RxSwift
import SwiftyJSON

class ArchiveEditRepositoryImplement: ArchiveEditRepository {
    
    func switchIsPublicArchive(id: Int, isPublic: Bool) -> Observable<Result<Void, ArchiveError>> {
        let provider = ArchiveProvider.shared.provider
        return provider.rx.request(.editIsPublicArchive(isPublic: isPublic, archiveId: id), callbackQueue: DispatchQueue.global())
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

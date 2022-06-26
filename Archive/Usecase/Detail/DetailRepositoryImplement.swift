//
//  DetailRepositoryImplement.swift
//  Archive
//
//  Created by hanwe on 2022/06/26.
//

import RxSwift
import Moya

class DetailRepositoryImplement: DetailRepository {
        
    func getDetailArchiveInfo(id: String) -> Observable<Result<ArchiveDetailInfo, ArchiveError>> {
        let provider = ArchiveProvider.shared.provider
        return provider.rx.request(.getDetailArchive(archiveId: id), callbackQueue: DispatchQueue.global())
            .asObservable()
            .map { result in
                if let info = ArchiveDetailInfo.fromJson(jsonData: result.data) {
                    return .success(info)
                } else {
                    return .failure(.init(.invaldData))
                }
            }
            .catch { err in
                return .just(.failure(.init(from: .server, code: err.responseCode, message: err.archiveErrMsg)))
            }
    }
}

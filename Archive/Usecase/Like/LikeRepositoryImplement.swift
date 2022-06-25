//
//  LikeRepositoryImplement.swift
//  Archive
//
//  Created by hanwe on 2022/06/25.
//

import RxSwift

class LikeRepositoryImplement: LikeRepository {
    
    func like(archiveId: Int) -> Observable<Result<Void, ArchiveError>> {
        let provider = ArchiveProvider.shared.provider
        return provider.rx.request(.like(archiveId: archiveId), callbackQueue: DispatchQueue.global())
        .asObservable()
        .map { result in
            if result.statusCode == 200 {
                return .success(())
            } else {
                return .failure(.init(from: .server, code: result.statusCode, message: "서버오류"))
            }
        }
        .catch { err in
            return .just(.failure(.init(from: .server, code: err.responseCode, message: err.archiveErrMsg)))
        }
    }
    
    func unlike(archiveId: Int) -> Observable<Result<Void, ArchiveError>> {
        let provider = ArchiveProvider.shared.provider
        return provider.rx.request(.unlike(archiveId: archiveId), callbackQueue: DispatchQueue.global())
        .asObservable()
        .map { result in
            if result.statusCode == 200 {
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

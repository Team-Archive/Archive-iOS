//
//  ReportRepositoryImplement.swift
//  Archive
//
//  Created by hanwe on 2022/09/12.
//

import RxSwift

class ReportRepositoryImplement: ReportRepository {
    
    // MARK: private property
    
    // MARK: internal property
    
    // MARK: lifeCycle
    
    // MARK: private function
    
    // MARK: internal function
    
    func report(archiveId: Int, reason: String) -> Observable<Result<Void, ArchiveError>> {
        let provider = ArchiveProvider.shared.provider
        return provider.rx.request(.report(archiveId: archiveId, reason: reason))
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

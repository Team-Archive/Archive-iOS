//
//  CommunityRepositoryImplement.swift
//  Archive
//
//  Created by hanwe on 2022/06/25.
//

import RxSwift
import Moya
import SwiftyJSON

class CommunityRepositoryImplement: CommunityRepository {
    
    // MARK: private property
    
    // MARK: internal property
    
    // MARK: lifeCycle
    
    // MARK: private function
    
    // MARK: internal function
    
    func getPublicArchives(sortBy: PublicArchiveSortBy, emotion: Emotion?, lastSeenArchiveDateMilli: Int?, lastSeenArchiveId: Int?) -> Observable<Result<String, ArchiveError>> {
        let provider = ArchiveProvider.shared.provider
        return provider.rx.request(.getPublicArchives(sortBy: sortBy.rawValue,
                                                      emotion: emotion?.rawValue,
                                                      lastSeenArchiveDateMilli: lastSeenArchiveDateMilli,
                                                      lastSeenArchiveId: lastSeenArchiveId)
                                   , callbackQueue: DispatchQueue.global())
            .asObservable()
            .map { result in
                if result.statusCode == 200 {
//                    guard let resultJson: JSON = try? JSON.init(data: result.data) else { return .failure(.init(.invaldData))}
//                    if resultJson["duplicatedEmail"].boolValue {
//                        return .success(true)
//                    } else {
//                        return .success(false)
//                    }
                    print("뭐가 왔네 : \(result)")
                    return .failure(.init(.archiveOAuthError))
                } else {
                    return .failure(.init(from: .server, code: result.statusCode, message: "서버오류"))
                }
            }
            .catch { err in
                    .just(.failure(.init(from: .server, code: err.responseCode, message: err.archiveErrMsg)))
            }
    }
    
}

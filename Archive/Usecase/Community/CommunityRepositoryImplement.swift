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
    
    func getPublicArchives(sortBy: PublicArchiveSortBy, emotion: Emotion?, lastSeenArchiveDateMilli: Int?, lastSeenArchiveId: Int?) -> Observable<Result<[PublicArchive], ArchiveError>> {
        let provider = ArchiveProvider.shared.provider
        return provider.rx.request(.getPublicArchives(sortBy: sortBy.rawValue,
                                                      emotion: emotion?.rawValue,
                                                      lastSeenArchiveDateMilli: lastSeenArchiveDateMilli,
                                                      lastSeenArchiveId: lastSeenArchiveId)
                                   , callbackQueue: DispatchQueue.global())
            .asObservable()
            .map { result in
                if result.statusCode == 200 {
                    guard let resultJson: JSON = try? JSON.init(data: result.data) else { return .failure(.init(.invaldData))}
                    let result: [PublicArchive] = {
                        var returnValue: [PublicArchive] = []
                        for item in resultJson {
                            guard let data = try? item.1.rawData() else { continue }
                            if let newItem = PublicArchive.fromJson(jsonData: data) {
                                returnValue.append(newItem)
                            }
                        }
                        return returnValue
                    }()
                    return .success(result)
                } else {
                    return .failure(.init(from: .server, code: result.statusCode, message: "서버오류"))
                }
            }
            .catch { err in
                    .just(.failure(.init(from: .server, code: err.responseCode, message: err.archiveErrMsg)))
            }
    }
    
}

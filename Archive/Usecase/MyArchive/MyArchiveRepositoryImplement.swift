//
//  MyArchiveRepositoryImplement.swift
//  Archive
//
//  Created by hanwe on 2022/07/16.
//

import RxSwift
import Moya
import SwiftyJSON

class MyArchiveRepositoryImplement: MyArchiveRepository {
    
    func getArchives(sortBy: ArchiveSortType, emotion: Emotion?, lastSeenArchiveDateMilli: Int?, lastSeenArchiveId: Int?) -> Observable<Result<[ArchiveInfo], ArchiveError>> {
        let provider = ArchiveProvider.shared.provider
        return provider.rx.request(.getPublicArchives(sortBy: sortBy.toAPIRawValue,
                                                      emotion: emotion?.rawStringValue,
                                                      lastSeenArchiveDateMilli: lastSeenArchiveDateMilli,
                                                      lastSeenArchiveId: lastSeenArchiveId),
                                   callbackQueue: DispatchQueue.global())
        .asObservable()
        .map { result in
            if result.statusCode == 200 {
                guard let resultJson: JSON = try? JSON.init(data: result.data) else { return .failure(.init(.invaldData))}
                let result: [ArchiveInfo] = {
                    var returnValue: [ArchiveInfo] = []
                    for item in resultJson {
                        guard let data = try? item.1.rawData() else { continue }
                        if let newItem = ArchiveInfo.fromJson(jsonData: data) {
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
            return .just(.failure(.init(from: .server, code: err.responseCode, message: err.archiveErrMsg)))
        }
    }
}

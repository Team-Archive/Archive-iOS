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
    
    func getArchives(sortBy: ArchiveSortType, emotion: Emotion?, lastSeenArchiveDateMilli: Int?, lastSeenArchiveId: Int?) -> Observable<Result<ArchiveInfoFull, ArchiveError>> {
        let provider = ArchiveProvider.shared.provider
        return provider.rx.request(.getArchives(sortBy: sortBy.toAPIRawValue,
                                                emotion: emotion?.rawStringValue,
                                                lastSeenArchiveDateMilli: lastSeenArchiveDateMilli,
                                                lastSeenArchiveId: lastSeenArchiveId),
                                   callbackQueue: DispatchQueue.global())
        .asObservable()
        .map { result in
            if result.statusCode == 200 {
                guard let resultJson: JSON = try? JSON.init(data: result.data) else { return .failure(.init(.invaldData))}
                let archiveInfo = resultJson["archives"].arrayValue
                let result: [ArchiveInfo] = {
                    var returnValue: [ArchiveInfo] = []
                    for item in archiveInfo {
                        guard let data = try? item.rawData() else { continue }
                        if let newItem = ArchiveInfo.fromJson(jsonData: data) {
                            returnValue.append(newItem)
                        }
                    }
                    return returnValue
                }()
                return .success(ArchiveInfoFull(archiveInfoList: result, totalCount: resultJson["archiveCount"].intValue))
            } else {
                return .failure(.init(from: .server, code: result.statusCode, message: "서버오류"))
            }
        }
        .catch { err in
            return .just(.failure(.init(from: .server, code: err.responseCode, message: err.archiveErrMsg)))
        }
    }
}

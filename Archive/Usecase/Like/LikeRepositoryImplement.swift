//
//  LikeRepositoryImplement.swift
//  Archive
//
//  Created by hanwe on 2022/06/25.
//

import RxSwift
import SwiftyJSON

class LikeRepositoryImplement: LikeRepository {
    
    func like(idList: [String]) -> Observable<Result<Void, ArchiveError>> {
        let provider = ArchiveProvider.shared.provider
        return provider.rx.request(.like(archiveIdList: idList), callbackQueue: DispatchQueue.global())
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
    
    func likeCancel(idList: [String]) -> Observable<Result<Void, ArchiveError>> {
        let provider = ArchiveProvider.shared.provider
        return provider.rx.request(.unlike(archiveIdList: idList), callbackQueue: DispatchQueue.global())
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
    
    func getMyLikeIdList() -> Observable<Result<Set<String>, ArchiveError>> {
        let provider = ArchiveProvider.shared.provider
        return provider.rx.request(.getMyLikeList, callbackQueue: DispatchQueue.global())
            .asObservable()
            .map { result in
                if result.statusCode == 200 {
                    guard let jsonData: JSON = try? JSON.init(data: result.data) else { return .failure(.init(.invaldData))}
                    let myLikeList = jsonData["archives"].arrayValue
                    var returnValue: Set<String> = []
                    for item in myLikeList {
                        if let id = item["archiveId"].int {
                            returnValue.insert("\(id)")
                        }
                    }
                    return .success(returnValue)
                } else {
                    return .failure(.init(from: .server, code: result.statusCode, message: "서버오류"))
                }
            }
            .catch { err in
                return .just(.failure(.init(from: .server, code: err.responseCode, message: err.archiveErrMsg)))
            }
    }
    
}

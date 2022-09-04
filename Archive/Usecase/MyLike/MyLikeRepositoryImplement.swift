//
//  MyLikeRepositoryImplement.swift
//  Archive
//
//  Created by hanwe on 2022/09/03.
//

import UIKit
import RxSwift
import SwiftyJSON

class MyLikeRepositoryImplement: MyLikeRepository {
    
    // MARK: private property
    
    // MARK: internal property
    
    // MARK: lifeCycle
    
    // MARK: private function
    
    // MARK: internal function
    
    func getMyLikeArchives() -> Observable<Result<[PublicArchive], ArchiveError>> {
        let provider = ArchiveProvider.shared.provider
        return provider.rx.request(.getMyLikeList, callbackQueue: DispatchQueue.global())
            .asObservable()
            .map { result in
                if result.statusCode == 200 {
                    guard let resultJson: JSON = try? JSON.init(data: result.data) else { return .failure(.init(.invaldData))}
                    let archives = resultJson["archives"].arrayValue
                    var returnValue: [PublicArchive] = []
                    for item in archives {
                        guard let data = try? item.rawData() else { continue }
                        if let newItem = PublicArchive.fromJson(jsonData: data) {
                            returnValue.append(newItem)
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

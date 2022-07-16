//
//  BannerRepositoryImplement.swift
//  Archive
//
//  Created by hanwe on 2022/07/16.
//

import SwiftyJSON
import RxSwift
import Moya

class BannerRepositoryImplement: BannerRepository {
    
    // MARK: private property
    
    // MARK: internal property
    
    // MARK: lifeCycle
    
    // MARK: private function
    
    // MARK: internal function
    
    func getBanner() -> Observable<Result<[BannerInfo], ArchiveError>> {
        let provider = ArchiveProvider.shared.provider
        return provider.rx.request(.getBanner, callbackQueue: DispatchQueue.global())
        .asObservable()
        .map { result in
            if result.statusCode == 200 {
                guard let resultJson: JSON = try? JSON.init(data: result.data) else { return .failure(.init(.invaldData))}
                let bannerItems: [BannerInfo] = {
                    var returnValue = [BannerInfo]()
                    let resultArr = resultJson["banners"].arrayValue
                    for item in resultArr {
                        let data = try? item.rawData()
                        if let element = BannerInfo.fromJson(jsonData: data) {
                            returnValue.append(element)
                        }
                    }
                    return returnValue
                }()
                return .success(bannerItems)
            } else {
                return .failure(.init(from: .server, code: result.statusCode, message: "서버오류"))
            }
        }
        .catch { err in
            return .just(.failure(.init(from: .server, code: err.responseCode, message: err.archiveErrMsg)))
        }
    }
    
}

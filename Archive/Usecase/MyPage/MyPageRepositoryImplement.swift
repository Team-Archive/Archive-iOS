//
//  MyPageRepositoryImplement.swift
//  Archive
//
//  Created by hanwe on 2022/07/30.
//

import RxSwift
import SwiftyJSON

class MyPageRepositoryImplement: MyPageRepository {
    
    func getCurrentUserInfo() -> Observable<Result<MyLoginInfo, ArchiveError>> {
        let provider = ArchiveProvider.shared.provider
        
        return provider.rx.request(.getCurrentUserInfo, callbackQueue: DispatchQueue.global())
            .asObservable()
            .map { result in
                if result.statusCode == 200 {
                    guard let jsonData: JSON = try? JSON.init(data: result.data) else { return .failure(.init(.invaldData))}
                    let mailAddr = jsonData["mailAddress"].stringValue
                    return .success(MyLoginInfo(email: mailAddr, loginType: LogInManager.shared.logInType))
                } else {
                    return .failure(.init(from: .server, code: result.statusCode, message: ""))
                }
            }
            .catch { err in
                return .just(.failure(.init(from: .server, code: err.responseCode, message: err.archiveErrMsg)))
            }
    }
}

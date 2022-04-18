//
//  EMailLogInRepositoryImplement.swift
//  Archive
//
//  Created by hanwe on 2022/04/18.
//

import RxSwift
import SwiftyJSON
import Moya

class EMailLogInRepositoryImplement: EMailLogInRepository {
    func loginEmail(eMail: String, password: String) -> Observable<Result<EMailLogInSuccessType, ArchiveError>> {
        let provider = ArchiveProvider.shared.provider
        let param = LoginEmailParam(email: eMail, password: password)
        return provider.rx.request(.loginEmail(param), callbackQueue: DispatchQueue.global())
            .asObservable()
            .map { result in
                if result.statusCode == 200 {
                    if let headers = result.response?.headers {
                        guard let token: String = headers["Authorization"] else {
                            return .failure(.init(.responseHeaderIsNull))
                        }
                        return .success(.logInSuccess(token: token))
                    } else {
                        return .failure(.init(.responseHeaderIsNull))
                    }
                } else if result.statusCode == 205 {
                    return .success(.isTempPW)
                } else {
                    return .failure(.init(from: .server, code: result.statusCode, message: "서버 오류"))
                }
                return .failure(.init(.invaldData))
            }
            .catch { err in
                    .just(.failure(.init(from: .network, code: (err as? MoyaError)?.errorCode ?? -1, message: "네트워크 오류")))
            }
    }
}

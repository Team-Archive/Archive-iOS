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
    func loginEmail(eMail: String, password: String) -> Observable<Result<EMailLogInSuccessData, ArchiveError>> {
        let provider = ArchiveProvider.shared.provider
        let param = LoginEmailParam(email: eMail, password: password)
        return provider.rx.request(.loginEmail(param), callbackQueue: DispatchQueue.global())
            .asObservable()
            .map { result in
                var isTempPw: Bool = false
                if result.statusCode == 200 {
                } else if result.statusCode == 205 {
                    isTempPw = true
                } else {
                    return .failure(.init(from: .server, code: result.statusCode, message: "서버 오류"))
                }
                if let headers = result.response?.headers {
                    guard let token: String = headers["Authorization"] else {
                        return .failure(.init(.responseHeaderIsNull))
                    }
                    return .success(.init(token: token, isTempPW: isTempPw))
                } else {
                    return .failure(.init(.responseHeaderIsNull))
                }
            }
            .catch { err in
                    .just(.failure(.init(from: .network, code: err.responseCode, message: err.archiveErrMsg)))
            }
    }
}

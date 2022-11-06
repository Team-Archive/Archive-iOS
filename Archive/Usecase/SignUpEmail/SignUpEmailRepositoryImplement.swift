//
//  SignUpEmailRepositoryImplement.swift
//  Archive
//
//  Created by hanwe on 2022/10/09.
//

import UIKit
import RxSwift
import SwiftyJSON

class SignUpEmailRepositoryImplement: SignUpEmailRepository {

    func registEmail(eMail: String, nickname: String, password: String) -> Observable<Result<String, ArchiveError>> {
        let provider = ArchiveProvider.shared.provider
        return provider.rx.request(.registEmail(email: eMail, nickname: nickname, password: password), callbackQueue: DispatchQueue.global())
            .asObservable()
            .map { result in
                if result.statusCode == 200 {
                    guard let token = result.response?.headers["Authorization"] else { return .success("")}
                    return .success(token)
                } else {
                    return .failure(.init(from: .server, code: result.statusCode, message: "서버오류"))
                }
            }
            .catch { err in
                return .just(.failure(.init(from: .server, code: err.responseCode, message: err.archiveErrMsg)))
            }
    }
    
    func checkIsDuplicatedEmail(eMail: String) -> Observable<Result<Bool, ArchiveError>> {
        let provider = ArchiveProvider.shared.provider
        return provider.rx.request(.isDuplicatedEmail(eMail), callbackQueue: DispatchQueue.global())
            .asObservable()
            .map { response in
                if let result: JSON = try? JSON.init(data: response.data) {
                    let isDup: Bool = result["duplicatedEmail"].boolValue
                    if isDup {
                        return .success(true)
                    } else {
                        return .success(false)
                    }
                } else {
                    return .success(true)
                }
            }
            .catch { err in
                return .just(.failure(.init(from: .server, code: err.responseCode, message: err.archiveErrMsg)))
            }
    }
    
}

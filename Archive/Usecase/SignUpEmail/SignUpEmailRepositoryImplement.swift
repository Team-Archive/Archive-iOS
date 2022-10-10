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

    func registEmail(eMail: String, password: String) -> Observable<Result<Void, ArchiveError>> {
        let provider = ArchiveProvider.shared.provider
        let param = RequestEmailParam(email: eMail, password: password)
        return provider.rx.request(.registEmail(param), callbackQueue: DispatchQueue.global())
            .asObservable()
            .map { result in
                return .success(Void())
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

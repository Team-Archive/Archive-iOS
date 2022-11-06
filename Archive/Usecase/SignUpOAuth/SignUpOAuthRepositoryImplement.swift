//
//  SignUpOAuthRepositoryImplement.swift
//  Archive
//
//  Created by hanwe on 2022/11/06.
//

import RxSwift
import SwiftyJSON

class SignUpOAuthRepositoryImplement: SignUpOAuthRepository {
    func registOAuth(nickname: String, oAuthProvider: LoginType, providerAccessToken: String) -> Observable<Result<String, ArchiveError>> {
        let provider = ArchiveProvider.shared.provider
        return provider.rx.request(.registOAuth(nickname: nickname, provider: oAuthProvider.rawValue, providerAccessToken: providerAccessToken), callbackQueue: DispatchQueue.global())
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
}

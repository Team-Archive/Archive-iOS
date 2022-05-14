//
//  LoginAccessTokenRepositoryImplement.swift
//  Archive
//
//  Created by hanwe on 2022/05/14.
//

import RxSwift

class LoginAccessTokenRepositoryImplement: LoginAccessTokenRepository {
    func isValidAccessToken() -> Observable<Bool> {
        let provider = ArchiveProvider.shared.provider
        return provider.rx.request(.getCurrentUserInfo, callbackQueue: DispatchQueue.global()) // 언젠가 전용 API 사용..?
            .asObservable()
            .map { _ in
                return true
            }
            .catch { _ in
                return .just(false)
            }
    }
}

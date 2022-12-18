//
//  SignUpOAuthRepository.swift
//  Archive
//
//  Created by hanwe on 2022/11/06.
//

import RxSwift

protocol SignUpOAuthRepository {
    func registOAuth(nickname: String, oAuthProvider: LoginType, providerAccessToken: String) -> Observable<Result<String, ArchiveError>>
}

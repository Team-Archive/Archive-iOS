//
//  LoginOAuthRepository.swift
//  Archive
//
//  Created by hanwe on 2022/03/19.
//

import RxSwift

public enum OAuthSignInType: String, Codable {
    case apple
    case kakao
}

protocol LoginOAuthRepository { // TODO: 추상화하기
    func getToken(type: OAuthSignInType, completion: @escaping (Result<String, ArchiveError>) -> Void)
    func isExistEmailWithKakao(accessToken: String) -> Observable<Bool>
    func isExistEmailWithApple(accessToken: String) -> Observable<Bool>
    func loginWithKakao(accessToken: String) -> Observable<Result<String, ArchiveError>>
    func loginWithApple(accessToken: String) -> Observable<Result<String, ArchiveError>>
    func isKakaotalkInstalled() -> Bool
}

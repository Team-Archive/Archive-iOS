//
//  LoginOAuthRepository.swift
//  Archive
//
//  Created by hanwe on 2022/03/19.
//

public enum OAuthSignInType: Codable {
    case apple
    case kakao
}

protocol LoginOAuthRepository {
    func getToken(type: OAuthSignInType, completion: @escaping (Result<String, ArchiveError>) -> Void)
}

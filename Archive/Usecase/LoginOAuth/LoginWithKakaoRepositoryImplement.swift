//
//  LoginWithKakaoRepositoryImplement.swift
//  Archive
//
//  Created by hanwe on 2022/03/20.
//

import UIKit
import KakaoSDKAuth
import KakaoSDKUser


class LoginWithKakaoRepositoryImplement: NSObject {
    
    func signIn(completion: @escaping (Result<String, ArchiveError>) -> Void) {
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.loginWithKakaoTalk { oAuthToken, error in
                if let error = error {
                    completion(.failure(.init(from: .kakaoOAuth, code: (error as NSError).code, message: error.localizedDescription)))
                } else {
                    guard let idToken = oAuthToken?.idToken else { completion(.failure(.init(.kakaoIdTokenIsNull))) ; return }
                    completion(.success(idToken))
                }
            }
        } else {
            completion(.failure(.init(.kakaoIsNotIntalled)))
        }
    }
}

//
//  LoginOAuthRepositoryImplement.swift
//  Archive
//
//  Created by hanwe on 2022/03/19.
//

class LoginOAuthRepositoryImplement: LoginOAuthRepository {
    
    // MARK: private property
    
    private let appleRepository: LoginWithAppleRepositoryImplement = LoginWithAppleRepositoryImplement()
    private let kakaoRepository: LoginWithKakaoRepositoryImplement = LoginWithKakaoRepositoryImplement()
    
    // MARK: internal property
    
    // MARK: lifeCycle
    
    // MARK: private function
    
    // MARK: internal function
    func getToken(type: OAuthSignInType, completion: @escaping (Result<String, ArchiveError>) -> Void) {
        switch type {
        case .apple:
            self.appleRepository.signIn(completion: completion)
        case .kakao:
            self.kakaoRepository.signIn(completion: completion)
        }
    }
    
}

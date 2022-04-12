//
//  LoginOAuthUsecase.swift
//  Archive
//
//  Created by hanwe on 2022/03/19.
//

import UIKit

class LoginOAuthUsecase: NSObject {
    
    // MARK: private property
    
    private let repository: LoginOAuthRepository
    
    // MARK: internal property
    
    // MARK: lifeCycle
    
    init(repository: LoginOAuthRepository) {
        self.repository = repository
    }
    
    // MARK: private function
    
    // MARK: internal function
    
    func getToken(type: OAuthSignInType, completion: @escaping (Result<String, ArchiveError>) -> Void) {
        self.repository.getToken(type: type, completion: completion)
    }
    
    func isExistEmailWithKakao(accessToken: String) -> Observable<Bool> {
        return self.repository.isExistEmailWithKakao(accessToken: accessToken)
    }
    
}

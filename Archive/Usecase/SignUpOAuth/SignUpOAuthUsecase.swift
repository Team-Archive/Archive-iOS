//
//  SignUpOAuthUsecase.swift
//  Archive
//
//  Created by hanwe on 2022/11/06.
//

import Foundation
import RxSwift

class SignUpOAuthUsecase: NSObject {
    
    // MARK: private property
    
    private let repository: SignUpOAuthRepository
    
    // MARK: internal property
    
    // MARK: lifeCycle
    
    init(repository: SignUpOAuthRepository) {
        self.repository = repository
    }
    
    // MARK: private function
    
    // MARK: internal function
    
    func registOAuth(nickname: String, provider: LoginType, providerAccessToken: String) -> Observable<Result<String, ArchiveError>> {
        return self.repository.registOAuth(nickname: nickname, oAuthProvider: provider, providerAccessToken: providerAccessToken)
    }

}

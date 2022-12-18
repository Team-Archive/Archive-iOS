//
//  LoginAccessTokenUsecase.swift
//  Archive
//
//  Created by hanwe on 2022/05/14.
//

import RxSwift

class LoginAccessTokenUsecase: NSObject {
    
    // MARK: private property
    
    private let repository: LoginAccessTokenRepository
    
    // MARK: internal property
    
    // MARK: lifeCycle
    
    init(repository: LoginAccessTokenRepository) {
        self.repository = repository
    }
    
    // MARK: private function
    
    // MARK: internal function
    
    func isValidAccessToken() -> Observable<Bool> {
        return self.repository.isValidAccessToken()
    }
    
}

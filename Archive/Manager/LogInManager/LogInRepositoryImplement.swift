//
//  LogInRepositoryImplement.swift
//  Archive
//
//  Created by hanwe on 2022/04/17.
//

import UIKit

class LogInRepositoryImplement: LogInRepository {
    
    // MARK: private property
    
    private let userDefaultManager: UserDefaultManager = UserDefaultManager()
    
    // MARK: internal property
    
    // MARK: lifeCycle
    
    // MARK: private function
    
    // MARK: internal function
    
    func logIn(_ token: String) {
        userDefaultManager.setLoginToken(token)
    }
    
    func logOut() {
        userDefaultManager.removeInfo(.loginToken)
    }
    
    func getLogInToken() -> String {
        return userDefaultManager.getInfo(.loginToken)
    }
    
}

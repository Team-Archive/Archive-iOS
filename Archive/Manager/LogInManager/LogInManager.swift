//
//  LogInManager.swift
//  Archive
//
//  Created by hanwe on 2022/04/17.
//

import UIKit

class LogInManager: NSObject {
    
    // MARK: private property
    
    private let repository: LogInRepository = LogInRepositoryImplement()
    
    // MARK: internal property
    
    lazy private(set) var isLoggedIn = getLogInToken() == "" ? false : true
    private(set) var logInType: LoginType = .eMail
    
    static let shared: LogInManager = {
        let instance = LogInManager()
        instance.logInType = instance.getLogInTypeFromRepository()
        return instance
    }()
    
    // MARK: lifeCycle
    
    // MARK: private function
    
    private func setLogInTypeToRepository(_ type: LoginType) {
        self.repository.setLogInType(type)
    }
    
    private func getLogInTypeFromRepository() -> LoginType {
        return self.repository.getLogInType()
    }
    
    // MARK: internal function
    
    func getLogInToken() -> String {
        return self.repository.getLogInToken()
    }
    
    func logIn(token: String, type: LoginType) {
        setLogInTypeToRepository(type)
        self.logInType = type
        self.repository.logIn(token)
    }
    
    func logOut() {
        self.repository.logOut()
    }

}

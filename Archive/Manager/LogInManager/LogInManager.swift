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
    
    static let shared: LogInManager = {
        let instance = LogInManager()
        return instance
    }()
    
    // MARK: lifeCycle
    
    // MARK: private function
    
    // MARK: internal function
    
    func getLogInToken() -> String {
        return self.repository.getLogInToken()
    }
    
    func logIn(_ token: String) {
        self.repository.logIn(token)
    }
    
    func logOut() {
        self.repository.logOut()
    }

}

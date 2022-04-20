//
//  UserDefaultManager.swift
//  Archive
//
//  Created by hanwe on 2021/12/04.
//

import UIKit

class UserDefaultManager: NSObject {
    
    enum UserDefaultInfoType: String {
        case loginToken
        case loginType
    }
    
    // MARK: private property
    
    private let manager = UserDefaults.standard
    
    // MARK: internal property
    
    // MARK: lifeCycle
    
    // MARK: private function
    
    // MARK: internal function
    
    func setLoginToken(_ token: String) {
        self.manager.set(token, forKey: UserDefaultInfoType.loginToken.rawValue)
    }
    
    func setLoginType(_ type: LoginType) {
        self.manager.set(type.rawValue, forKey: UserDefaultInfoType.loginType.rawValue)
    }
    
    func getInfo(_ type: UserDefaultManager.UserDefaultInfoType) -> String {
        switch type {
        case .loginToken:
            return (manager.object(forKey: UserDefaultInfoType.loginToken.rawValue) as? String) ?? ""
        case .loginType:
            return (manager.object(forKey: UserDefaultInfoType.loginType.rawValue) as? String) ?? ""
        }
    }
    
    func removeInfo(_ type: UserDefaultManager.UserDefaultInfoType) {
        switch type {
        case .loginToken:
            manager.set(nil, forKey: UserDefaultInfoType.loginToken.rawValue)
        case .loginType:
            manager.set(nil, forKey: UserDefaultInfoType.loginType.rawValue)
        }
    }

}

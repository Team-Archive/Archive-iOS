//
//  LogInRepository.swift
//  Archive
//
//  Created by hanwe on 2022/04/17.
//

protocol LogInRepository {
    func logIn(_ token: String)
    func logOut()
    func getLogInToken() -> String
    func getLogInType() -> LoginType
    func setLogInType(_ type: LoginType)
}

enum LoginType: String {
    case eMail
    case kakao
    case apple
}

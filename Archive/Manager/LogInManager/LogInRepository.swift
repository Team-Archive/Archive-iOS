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
}

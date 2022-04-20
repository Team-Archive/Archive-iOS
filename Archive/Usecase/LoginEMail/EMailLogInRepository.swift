//
//  EMailLogInRepository.swift
//  Archive
//
//  Created by hanwe on 2022/04/18.
//

import RxSwift

protocol EMailLogInRepository {
    func loginEmail(eMail: String, password: String) -> Observable<Result<EMailLogInSuccessType, ArchiveError>>
}

enum EMailLogInSuccessType {
    case logInSuccess(token: String)
    case isTempPW
}

//
//  SignUpEmailRepository.swift
//  Archive
//
//  Created by hanwe on 2022/10/09.
//

import RxSwift
import Foundation

protocol SignUpEmailRepository {
    func registEmail(eMail: String, nickname: String, password: String) -> Observable<Result<String, ArchiveError>>
    func checkIsDuplicatedEmail(eMail: String) -> Observable<Result<Bool, ArchiveError>>
}

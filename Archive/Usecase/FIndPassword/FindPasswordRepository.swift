//
//  FindPasswordRepository.swift
//  Archive
//
//  Created by hanwe on 2022/04/16.
//

import RxSwift

protocol FindPasswordRepository {
    func isExistEmail(email: String) -> Observable<Result<Bool, ArchiveError>>
    func sendTempPassword(email: String) -> Observable<Result<Void, ArchiveError>>
    func changePassword(eMail: String, currentPassword: String, newPassword: String) -> Observable<Result<Void, ArchiveError>>
    func withdrawal() -> Observable<Result<Void, ArchiveError>>
}

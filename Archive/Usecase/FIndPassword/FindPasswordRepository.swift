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
}

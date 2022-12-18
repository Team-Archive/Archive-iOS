//
//  MyPageRepository.swift
//  Archive
//
//  Created by hanwe on 2022/07/30.
//

import RxSwift

protocol MyPageRepository {
    func getCurrentUserInfo() -> Observable<Result<MyLoginInfo, ArchiveError>>
}

struct MyLoginInfo {
    let email: String
    let loginType: LoginType
}

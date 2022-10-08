//
//  NickNameDuplicationRepository.swift
//  Archive
//
//  Created by hanwe on 2022/09/24.
//

import RxSwift

protocol NickNameDuplicationRepository {
    func isDuplicatedNickName(_ nickName: String) -> Observable<Result<Bool, ArchiveError>>
}

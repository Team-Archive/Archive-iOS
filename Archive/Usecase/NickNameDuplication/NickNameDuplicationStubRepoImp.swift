//
//  NickNameDuplicationStubRepoImp.swift
//  Archive
//
//  Created by hanwe on 2022/09/24.
//

import RxSwift

class NickNameDuplicationStubRepoImp: NickNameDuplicationRepository {
    func isDuplicatedNickName(_ nickName: String) -> Observable<Result<Bool, ArchiveError>> {
        return .just(.success(false))
    }
}

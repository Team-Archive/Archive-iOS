//
//  NickNameDuplicationRepositoryImplement.swift
//  Archive
//
//  Created by hanwe on 2022/09/24.
//

import RxSwift
import SwiftyJSON

class NickNameDuplicationRepositoryImplement: NickNameDuplicationRepository {
    func isDuplicatedNickName(_ nickName: String) -> Observable<Result<Bool, ArchiveError>> { // TODO: API나오면 구현
        return .just(.success(false))
    }
}

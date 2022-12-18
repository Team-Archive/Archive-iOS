//
//  NickNameDuplicationRepositoryImplement.swift
//  Archive
//
//  Created by hanwe on 2022/09/24.
//

import RxSwift
import SwiftyJSON

class NickNameDuplicationRepositoryImplement: NickNameDuplicationRepository {
    func isDuplicatedNickName(_ nickName: String) -> Observable<Result<Bool, ArchiveError>> {
        let provider = ArchiveProvider.shared.provider
        return provider.rx.request(.getIsDuplicatedNickname(nickName))
            .asObservable()
            .map { result in
                if result.statusCode == 200 {
                    guard let resultJson: JSON = try? JSON.init(data: result.data) else { return .failure(.init(.invaldData))}
                    return .success(resultJson["isDuplicatedNickname"].boolValue)
                } else {
                    return .failure(.init(from: .server, code: result.statusCode, message: "서버오류"))
                }
            }
            .catch { err in
                return .just(.failure(.init(from: .server, code: err.responseCode, message: err.archiveErrMsg)))
            }
    }
}

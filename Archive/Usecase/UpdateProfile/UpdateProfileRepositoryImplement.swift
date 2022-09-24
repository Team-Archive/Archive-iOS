//
//  UpdateProfileRepositoryImplement.swift
//  Archive
//
//  Created by hanwe on 2022/09/24.
//

import RxSwift

class UpdateProfileRepositoryImplement: UpdateProfileRepository {
    func updateProfile(imageUrl: String?, nickName: String?) -> Observable<Result<Void, ArchiveError>> {
        return .just(.success(()))
    }

}

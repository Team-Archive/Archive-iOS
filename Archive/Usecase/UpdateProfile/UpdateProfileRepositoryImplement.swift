//
//  UpdateProfileRepositoryImplement.swift
//  Archive
//
//  Created by hanwe on 2022/09/24.
//

import RxSwift

class UpdateProfileRepositoryImplement: UpdateProfileRepository {
    func updateProfile(updataProfileData: UpdateProfileData) -> Observable<Result<ProfileData, ArchiveError>> {
        return .just(.failure(.init(.archiveDataIsInvaild)))
    }
}

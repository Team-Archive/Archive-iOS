//
//  UpdateProfileStubImpl.swift
//  Archive
//
//  Created by hanwe on 2022/09/24.
//

import RxSwift

class UpdateProfileStubImpl: UpdateProfileRepository {
    func updateProfile(updataProfileData: UpdateProfileData) -> Observable<Result<ProfileData, ArchiveError>> {
        return .just(.success(ProfileData(imageUrl: "https://naver.com",
                                                      nickNmae: "새로운 닉네임")))
    }
}

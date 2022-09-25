//
//  UpdateProfileStubImpl.swift
//  Archive
//
//  Created by hanwe on 2022/09/24.
//

import RxSwift

class UpdateProfileStubImpl: UpdateProfileRepository {
    func updateProfile(updataProfileData: UpdateProfileData) -> Observable<Result<UpdateProfileResultData, ArchiveError>> {
        return .just(.success(UpdateProfileResultData(imageUrl: "https://naver.com",
                                                      nickNmae: "새로운 닉네임")))
    }
}

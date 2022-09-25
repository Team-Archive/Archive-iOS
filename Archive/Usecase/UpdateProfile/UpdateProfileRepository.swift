//
//  UpdateProfileRepository.swift
//  Archive
//
//  Created by hanwe on 2022/09/24.
//

import RxSwift

protocol UpdateProfileRepository {
    func updateProfile(updataProfileData: UpdateProfileData) -> Observable<Result<ProfileData, ArchiveError>>
}

struct UpdateProfileData {
    let imageUrl: String?
    let nickNmae: String?
}

struct ProfileData {
    let imageUrl: String
    let nickNmae: String
}

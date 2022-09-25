//
//  UpdateProfileRepository.swift
//  Archive
//
//  Created by hanwe on 2022/09/24.
//

import RxSwift

protocol UpdateProfileRepository {
    func updateProfile(updataProfileData: UpdateProfileData) -> Observable<Result<UpdateProfileResultData, ArchiveError>>
}

struct UpdateProfileData {
    let imageUrl: String?
    let nickNmae: String?
}

struct UpdateProfileResultData {
    let imageUrl: String
    let nickNmae: String
}

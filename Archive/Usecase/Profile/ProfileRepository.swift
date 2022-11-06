//
//  UpdateProfileRepository.swift
//  Archive
//
//  Created by hanwe on 2022/09/24.
//

import RxSwift

protocol ProfileRepository {
    func updateNickname(_ newNickname: String) -> Observable<Result<Void, ArchiveError>>
}

struct UpdateProfileData {
    let imageUrl: String?
    let nickNmae: String?
}

struct ProfileData {
    let imageUrl: String
    let nickNmae: String
}

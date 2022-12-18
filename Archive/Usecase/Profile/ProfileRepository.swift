//
//  UpdateProfileRepository.swift
//  Archive
//
//  Created by hanwe on 2022/09/24.
//

import RxSwift

protocol ProfileRepository {
    func updateNickname(_ newNickname: String) -> Observable<Result<Void, ArchiveError>>
    func getProfile() -> Observable<Result<ProfileData, ArchiveError>>
}

struct UpdateProfileData {
    let imageUrl: String?
    let nickNmae: String?
}

struct ProfileData: CodableWrapper {
    typealias selfType = ProfileData
    
    let userId: Int
    let mail: String
    let imageUrl: String
    let nickNmae: String
    
    enum CodingKeys: String, CodingKey {
        case userId
        case mail = "mailAddress"
        case imageUrl = "profileImage"
        case nickNmae = "nickname"
    }
}

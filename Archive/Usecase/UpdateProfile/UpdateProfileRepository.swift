//
//  UpdateProfileRepository.swift
//  Archive
//
//  Created by hanwe on 2022/09/24.
//

import RxSwift

protocol UpdateProfileRepository {
    func updateProfile(imageUrl: String?, nickName: String?) -> Observable<Result<Void, ArchiveError>>
}

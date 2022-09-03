//
//  LikeRepository.swift
//  Like
//
//  Created by Hanwe LEE on 2022/08/30.
//

import RxSwift

protocol LikeRepository {
    func like(idList: [String]) -> Observable<Result<Void, ArchiveError>>
    func likeCancel(idList: [String]) -> Observable<Result<Void, ArchiveError>>
    func getMyLikeIdList() -> Observable<Result<Set<String>, ArchiveError>>
}

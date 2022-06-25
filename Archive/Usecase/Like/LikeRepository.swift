//
//  LikeRepository.swift
//  Archive
//
//  Created by hanwe on 2022/06/25.
//

import RxSwift

protocol LikeRepository {
    func like(archiveId: Int) -> Observable<Result<Void, ArchiveError>>
    func unlike(archiveId: Int) -> Observable<Result<Void, ArchiveError>>
}

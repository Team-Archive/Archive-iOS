//
//  MyLikeRepository.swift
//  Archive
//
//  Created by hanwe on 2022/07/31.
//

import RxSwift
import RxDataSources

protocol MyLikeRepository {
    func getMyLikeArchives() -> Observable<Result<[PublicArchive], ArchiveError>>
}

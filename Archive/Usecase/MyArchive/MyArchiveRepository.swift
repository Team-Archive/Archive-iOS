//
//  MyArchiveRepository.swift
//  Archive
//
//  Created by hanwe on 2022/07/16.
//

import RxSwift

protocol MyArchiveRepository {
    func getArchives(sortBy: ArchiveSortType, emotion: Emotion?, lastSeenArchiveDateMilli: Int?, lastSeenArchiveId: Int?) -> Observable<Result<[ArchiveInfo], ArchiveError>>
}

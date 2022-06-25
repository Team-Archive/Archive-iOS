//
//  CommunityRepository.swift
//  Archive
//
//  Created by hanwe on 2022/06/25.
//

import RxSwift

protocol CommunityRepository {
    func getPublicArchives(sortBy: PublicArchiveSortBy, emotion: Emotion?, lastSeenArchiveDateMilli: Int?, lastSeenArchiveId: Int?) -> Observable<Result<String, ArchiveError>>
}
enum PublicArchiveSortBy: String {
    case createdAt = "CREATED_AT"
    case watchedOn = "WATCHED_ON"
}

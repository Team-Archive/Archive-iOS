//
//  CommunityRepository.swift
//  Archive
//
//  Created by hanwe on 2022/06/25.
//

import RxSwift
import RxDataSources

protocol CommunityRepository {
    func getPublicArchives(sortBy: ArchiveSortType, emotion: Emotion?, lastSeenArchiveDateMilli: Int?, lastSeenArchiveId: Int?) -> Observable<Result<[PublicArchive], ArchiveError>>
}

struct PublicArchive: CodableWrapper {
    typealias selfType = PublicArchive
    
    let authorId: Int
    let mainImage: String
    let authorProfileImage: String
    let archiveName: String
    let archiveId: Int
    let authorNickname: String
    let emotion: Emotion
    let watchedOn: String
    let dateMilli: Int?
    var likeCount: Int
    var coverType: CoverType
    
    enum CodingKeys: String, CodingKey {
        case authorId
        case mainImage
        case authorProfileImage
        case archiveName = "name"
        case archiveId
        case authorNickname
        case emotion
        case watchedOn
        case dateMilli
        case likeCount
        case coverType = "coverImageType"
    }
    
}

extension PublicArchive: IdentifiableType, Equatable {
    typealias Identity = Int

    var identity: Identity { return self.archiveId }
}

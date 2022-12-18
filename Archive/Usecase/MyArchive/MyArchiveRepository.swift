//
//  MyArchiveRepository.swift
//  Archive
//
//  Created by hanwe on 2022/07/16.
//

import RxSwift

protocol MyArchiveRepository {
    func getArchives(sortBy: ArchiveSortType, emotion: Emotion?, lastSeenArchiveDateMilli: Int?, lastSeenArchiveId: Int?) -> Observable<Result<ArchiveInfoFull, ArchiveError>>
}

struct ArchiveInfoFull {
    let archiveInfoList: [ArchiveInfo]
    let totalCount: Int
}

struct ArchiveInfo: CodableWrapper {
    typealias selfType = ArchiveInfo
    
    let archiveId: Int
    let authorId: Int
    let archiveName: String
    let watchedOn: String
    let emotion: Emotion
//    let companions: [String]?
    let mainImageUrl: String
    let isPublic: Bool
//    let authorNickname: String
    let dateMilli: Int
//    let isLiked: Bool
//    let authorProfileImageUrl: String
    let likeCount: Int
    
    
    enum CodingKeys: String, CodingKey {
        case archiveId
        case authorId
        case archiveName = "name"
        case watchedOn
        case emotion
//        case companions
        case mainImageUrl = "mainImage"
        case isPublic
//        case authorNickname
        case dateMilli
//        case isLiked
//        case authorProfileImageUrl = "authorProfileImage"
        case likeCount
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.archiveId = try container.decode(Int.self, forKey: .archiveId)
        self.authorId = try container.decode(Int.self, forKey: .authorId)
        self.archiveName = try container.decode(String.self, forKey: .archiveName)
        self.watchedOn = try container.decode(String.self, forKey: .watchedOn)
        let emotionRawValue = try container.decode(String.self, forKey: .emotion)
        self.emotion = Emotion.fromString(emotionRawValue) ?? .fun
//        self.companions = try? container.decode([String].self, forKey: .companions)
        self.mainImageUrl = try container.decode(String.self, forKey: .mainImageUrl)
        self.isPublic = try container.decode(Bool.self, forKey: .isPublic)
//        self.authorNickname = try container.decode(String.self, forKey: .authorNickname)
        self.dateMilli = try container.decode(Int.self, forKey: .dateMilli)
//        self.isLiked = try container.decode(Bool.self, forKey: .isLiked)
//        self.authorProfileImageUrl = try container.decode(String.self, forKey: .authorProfileImageUrl)
        self.likeCount = try container.decode(Int.self, forKey: .likeCount)
    }
    
}

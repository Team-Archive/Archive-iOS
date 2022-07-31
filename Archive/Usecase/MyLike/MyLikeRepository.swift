//
//  MyLikeRepository.swift
//  Archive
//
//  Created by hanwe on 2022/07/31.
//

import RxSwift
import RxDataSources

protocol MyLikeRepository {
    func getMyLikeArchives() -> Observable<Result<[MyLikeArchive], ArchiveError>>
}

struct MyLikeArchive: CodableWrapper {
    typealias selfType = MyLikeArchive
    
    let authorId: Int
    let mainImage: String
    let authorProfileImage: String
    let archiveName: String
    var isLiked: Bool
    let archiveId: Int
    let authorNickname: String
    let emotion: Emotion
    let watchedOn: String
    let dateMilli: Int
    let likeCount: Int
    
    enum CodingKeys: String, CodingKey {
        case authorId
        case mainImage
        case authorProfileImage
        case archiveName = "name"
        case isLiked
        case archiveId
        case authorNickname
        case emotion
        case watchedOn
        case dateMilli
        case likeCount
    }
    
}

extension MyLikeArchive: IdentifiableType, Equatable {
    typealias Identity = Int

    var identity: Identity { return self.archiveId }
}

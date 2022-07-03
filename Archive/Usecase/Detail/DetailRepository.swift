//
//  DetailRepository.swift
//  Archive
//
//  Created by hanwe on 2022/06/26.
//

import RxSwift

protocol DetailRepository {
    func getDetailArchiveInfo(id: String) -> Observable<Result<ArchiveDetailInfo, ArchiveError>>
}

struct ArchiveDetailInfo: CodableWrapper, Equatable {
    typealias selfType = ArchiveDetailInfo
    
    let archiveId: Int
    let authorId: Int
    let name: String
    let watchedOn: String
    let emotion: Emotion
    let companions: [String]?
    let mainImage: String
    let images: [ArchiveDetailImageInfo]?
}

struct ArchiveDetailImageInfo: CodableWrapper {
    typealias selfType = ArchiveDetailImageInfo
    
    let review: String
    let image: String
    let backgroundColor: String
    let archiveImageId: Int
}

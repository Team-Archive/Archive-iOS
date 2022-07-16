//
//  BannerRepository.swift
//  Archive
//
//  Created by hanwe on 2022/07/16.
//

import RxSwift

protocol BannerRepository {
    func getBanner() -> Observable<Result<[BannerInfo], ArchiveError>>
}

struct BannerInfo: CodableWrapper {
    typealias selfType = BannerInfo
    
    let contentsImageUrl: String?
    let summaryImageUrl: String
    
    enum CodingKeys: String, CodingKey {
        case contentsImageUrl = "mainImage"
        case summaryImageUrl = "summaryImage"
    }
    
}

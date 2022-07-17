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
    
    enum BannerType: String {
        case url = "URL"
        case image = "IMAGE"
    }
    
    let mainContentUrl: String?
    let summaryImageUrl: String
    let type: BannerType
    
    enum CodingKeys: String, CodingKey {
        case mainContentUrl = "mainContent"
        case summaryImageUrl = "summaryImage"
        case type
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.mainContentUrl = try? container.decode(String.self, forKey: .mainContentUrl)
        self.summaryImageUrl = try container.decode(String.self, forKey: .summaryImageUrl)
        let typeRawValue = try container.decode(String.self, forKey: .type)
        if typeRawValue == "IMAGE" {
            self.type = .image
        } else {
            self.type = .url
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.summaryImageUrl, forKey: .summaryImageUrl)
        try? container.encode(self.mainContentUrl, forKey: .mainContentUrl)
        try container.encode(self.type.rawValue, forKey: .type)
    }
    
}

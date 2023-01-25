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
    let nickname: String
    let profileImage: String
    let coverType: CoverType
    
    enum CodingKeys: String, CodingKey {
        case archiveId
        case authorId
        case name
        case watchedOn
        case emotion
        case companions
        case mainImage
        case images
        case nickname
        case profileImage
        case coverType = "coverImageType"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.archiveId = try container.decode(Int.self, forKey: .archiveId)
        self.authorId = try container.decode(Int.self, forKey: .authorId)
        self.name = try container.decode(String.self, forKey: .name)
        self.watchedOn = try container.decode(String.self, forKey: .watchedOn)
        let emotionRawValue = try container.decode(String.self, forKey: .emotion)
        self.emotion = Emotion.fromString(emotionRawValue) ?? .fun
        self.companions = try? container.decode([String].self, forKey: .companions)
        self.mainImage = try container.decode(String.self, forKey: .mainImage)
        self.images = try? container.decode([ArchiveDetailImageInfo].self, forKey: .images)
        self.nickname = try container.decode(String.self, forKey: .nickname)
        self.profileImage = try container.decode(String.self, forKey: .profileImage)
        if let coverTypeRawValue = try? container.decode(String.self, forKey: .coverType) {
            self.coverType = CoverType.coverTypeFromRawValue(coverTypeRawValue) ?? .cover
        } else {
            self.coverType = .cover
        }
        
    }
    
    init() {
        self.coverType = .cover
        self.archiveId = 0
        self.authorId = 0
        self.name = ""
        self.watchedOn = ""
        self.emotion = .pleasant
        self.companions = []
        self.mainImage = ""
        self.images = []
        self.nickname = ""
        self.profileImage = ""
    }
    
}

struct ArchiveDetailImageInfo: CodableWrapper {
    typealias selfType = ArchiveDetailImageInfo
    
    let review: String
    let image: String
    let backgroundColor: String
    let archiveImageId: Int
}

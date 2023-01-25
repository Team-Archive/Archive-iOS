//
//  RegistRepositoty.swift
//  Archive
//
//  Created by hanwe on 2022/08/28.
//

import RxSwift

protocol RegistRepositoty {
    func uploadImages(_ images: [UIImage]) -> Observable<Result<[String], ArchiveError>>
    func regist(info: RecordData) -> Observable<Result<Void, ArchiveError>>
    func getThisMonthRegistCnt() -> Observable<Result<Int, ArchiveError>>
}

struct UploadImageInfo {
    let imageUrl: String
    let themeColor: String
}

struct RecordData: CodableWrapper {
    typealias selfType = RecordData
    
    let name: String
    let watchedOn: String
    let companions: [String]?
    let emotion: String
    let mainImage: String
    let images: [RecordImageData]?
    let isPublic: Bool
    let coverImageType: CoverType
    
}

struct RecordImageData: CodableWrapper {
    typealias selfType = RecordImageData
    
    let image: String
    let review: String
    let backgroundColor: String
}

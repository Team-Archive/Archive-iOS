//
//  RegistRepositoty.swift
//  Archive
//
//  Created by hanwe on 2022/08/28.
//

import RxSwift

protocol RegistRepositoty {
    func uploadImages(_ images: [UIImage]) -> Observable<Result<[String], ArchiveError>>
}

struct UploadImageInfo {
    let imageUrl: String
    let themeColor: String
}

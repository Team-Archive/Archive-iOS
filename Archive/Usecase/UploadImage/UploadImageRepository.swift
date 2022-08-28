//
//  UploadImageRepository.swift
//  Archive
//
//  Created by hanwe on 2022/08/28.
//

import RxSwift

protocol UploadImageRepository {
    func uploadImage(_ image: UIImage) -> Observable<Result<String, ArchiveError>>
}

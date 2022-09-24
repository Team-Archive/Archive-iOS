//
//  UploadImageRepository.swift
//  Archive
//
//  Created by hanwe on 2022/08/28.
//

import RxSwift

protocol UploadImageRepository {
    func uploadImage(_ imageData: Data) -> Observable<Result<String, ArchiveError>>
}

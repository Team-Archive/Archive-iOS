//
//  UploadProfilePhotoImageRepository.swift
//  Archive
//
//  Created by hanwe on 2022/11/02.
//

import RxSwift

protocol UploadProfilePhotoImageRepository {
    func uploadImage(_ imageData: Data) -> Observable<Result<String, ArchiveError>>
}

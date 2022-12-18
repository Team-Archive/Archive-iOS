//
//  ArchiveEditRepository.swift
//  Archive
//
//  Created by hanwe on 2022/12/17.
//

import RxSwift

protocol ArchiveEditRepository {
    func switchIsPublicArchive(id: Int, isPublic: Bool) -> Observable<Result<Void, ArchiveError>>
}

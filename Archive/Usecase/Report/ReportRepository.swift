//
//  ReportRepository.swift
//  Archive
//
//  Created by hanwe on 2022/09/12.
//

import RxSwift

protocol ReportRepository {
    func report(archiveId: Int, reason: String) -> Observable<Result<Void, ArchiveError>>
}

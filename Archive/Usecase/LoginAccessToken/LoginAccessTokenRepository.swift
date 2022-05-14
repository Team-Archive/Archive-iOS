//
//  LoginAccessTokenRepository.swift
//  Archive
//
//  Created by hanwe on 2022/05/14.
//

import RxSwift

protocol LoginAccessTokenRepository {
    func isValidAccessToken() -> Observable<Bool>
}

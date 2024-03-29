//
//  SignUpEmailUsecase.swift
//  Archive
//
//  Created by hanwe on 2022/10/09.
//

import Foundation
import RxSwift

class SignUpEmailUsecase: NSObject {
    
    // MARK: private property
    
    private let repository: SignUpEmailRepository
    
    // MARK: internal property
    
    // MARK: lifeCycle
    
    init(repository: SignUpEmailRepository) {
        self.repository = repository
    }
    
    // MARK: private function
    
    // MARK: internal function
    
    func registEmail(eMail: String, nickname: String, password: String) -> Observable<Result<String, ArchiveError>> {
        return self.repository.registEmail(eMail: eMail, nickname: nickname, password: password)
    }
    
    func checkIsDuplicatedEmail(eMail: String) -> Observable<Result<Bool, ArchiveError>> {
        return self.repository.checkIsDuplicatedEmail(eMail: eMail)
    }

}

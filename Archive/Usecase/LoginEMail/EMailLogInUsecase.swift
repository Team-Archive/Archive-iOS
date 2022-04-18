//
//  EMailLogInUsecase.swift
//  Archive
//
//  Created by hanwe on 2022/04/18.
//

import RxSwift

class EMailLogInUsecase: NSObject {
    
    // MARK: private property
    
    private let repository: EMailLogInRepository
    
    // MARK: internal property
    
    // MARK: lifeCycle
    
    init(repository: EMailLogInRepository) {
        self.repository = repository
    }
    
    // MARK: private function
    
    // MARK: internal function
    
    func loginEmail(eMail: String, password: String) -> Observable<Result<EMailLogInSuccessType, ArchiveError>> {
        return self.loginEmail(eMail: eMail, password: password)
    }
    
}

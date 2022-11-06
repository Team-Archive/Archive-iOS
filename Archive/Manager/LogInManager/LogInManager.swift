//
//  LogInManager.swift
//  Archive
//
//  Created by hanwe on 2022/04/17.
//

import UIKit
import RxSwift

class LogInManager: NSObject {
    
    // MARK: private property
    
    private let repository: LogInRepository = LogInRepositoryImplement()
    private let profileUsecase = ProfileUsecase(repository: ProfileRepositoryImplement(),
                                                uploadImageRepository: UploadProfilePhotoImageRepositoryImplement())
    
    private let disposeBag = DisposeBag()
    
    // MARK: internal property
    
    lazy private(set) var isLoggedIn = accessToken == "" ? false : true
    private(set) var logInType: LoginType = .eMail
    
    static let shared: LogInManager = {
        let instance = LogInManager()
        instance.logInType = instance.getLogInTypeFromRepository()
        return instance
    }()
    
    var accessToken: String {
        return self.repository.getLogInToken()
    }
    
    var profile: ProfileData = ProfileData(userId: -1, mail: "", imageUrl: "", nickNmae: "") {
        didSet {
            self.profileSubject.onNext(profile)
        }
    }
    
    lazy var profileSubject: BehaviorSubject<ProfileData> = .init(value: self.profile)
    
    var myTotalArchiveCnt: Int = 0
    
    // MARK: lifeCycle
    
    // MARK: private function
    
    private func setLogInTypeToRepository(_ type: LoginType) {
        self.repository.setLogInType(type)
    }
    
    private func getLogInTypeFromRepository() -> LoginType {
        return self.repository.getLogInType()
    }
    
    // MARK: internal function
    
    func logIn(token: String, type: LoginType) {
        setLogInTypeToRepository(type)
        self.logInType = type
        self.repository.logIn(token)
        LikeManager.shared.refreshMyLikeList()
    }
    
    func logOut() {
        self.repository.logOut()
    }
    
    func refreshProfile() {
        self.profileUsecase.getProfile().subscribe(onNext: { [weak self] profileResult in
            switch profileResult {
            case .success(let profileInfo):
                self?.profile = profileInfo
            case .failure(let err):
                print("프로필 가져오기 실패: \(err.getMessage())")
            }
        })
        .disposed(by: self.disposeBag)
    }

}

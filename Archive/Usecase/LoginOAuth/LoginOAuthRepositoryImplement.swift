//
//  LoginOAuthRepositoryImplement.swift
//  Archive
//
//  Created by hanwe on 2022/03/19.
//

import RxSwift
import SwiftyJSON

class LoginOAuthRepositoryImplement: LoginOAuthRepository {
    
    // MARK: private property
    
    private let appleRepository: LoginWithAppleRepositoryImplement = LoginWithAppleRepositoryImplement()
    private let kakaoRepository: LoginWithKakaoRepositoryImplement = LoginWithKakaoRepositoryImplement()
    private let disposeBag: DisposeBag = DisposeBag()
    
    // MARK: internal property
    
    // MARK: lifeCycle
    
    // MARK: private function
    
    // MARK: internal function
    func getToken(type: OAuthSignInType, completion: @escaping (Result<String, ArchiveError>) -> Void) {
        switch type {
        case .apple:
            self.appleRepository.signIn(completion: completion)
        case .kakao:
            self.kakaoRepository.signIn(completion: completion)
        }
    }
    
    func isExistEmailWithKakao(accessToken: String) -> Observable<Bool> {
        return Observable.create { [weak self] emitter in
            let provider = ArchiveProvider.shared.provider
            provider.rx.request(.getKakaoUserInfo(kakaoAccessToken: accessToken), callbackQueue: DispatchQueue.global())
                .asObservable()
                .subscribe(onNext: { [weak self] result in
                    switch result.statusCode {
                    case 200:
                        if let resultJson: JSON = try? JSON.init(data: result.data) {
                            let email: String = resultJson["kakao_account"]["email"].stringValue
                            if email == "" {
                                emitter.onNext(false)
                                emitter.onCompleted()
                            } else {
                                provider.rx.request(.isDuplicatedEmail(email))
                                    .asObservable()
                                    .subscribe(onNext: { [weak self] isDuplicatedEmailResponse in
                                        switch isDuplicatedEmailResponse.statusCode {
                                        case 200:
                                            if let resultJson: JSON = try? JSON.init(data: isDuplicatedEmailResponse.data) {
                                                let isDup = resultJson["duplicatedEmail"].boolValue
                                                if isDup {
                                                    emitter.onNext(true)
                                                    emitter.onCompleted()
                                                } else {
                                                    emitter.onNext(false)
                                                    emitter.onCompleted()
                                                }
                                            } else {
                                                emitter.onNext(false)
                                                emitter.onCompleted()
                                            }
                                        default:
                                            emitter.onNext(false)
                                            emitter.onCompleted()
                                        }
                                    })
                                    .disposed(by: self?.disposeBag ?? DisposeBag())
                            }
                        } else {
                            emitter.onNext(false)
                            emitter.onCompleted()
                        }
                    default:
                        emitter.onNext(false)
                        emitter.onCompleted()
                    }
                })
                .disposed(by: self?.disposeBag ?? DisposeBag())
            return Disposables.create()
        }
    }
    
}

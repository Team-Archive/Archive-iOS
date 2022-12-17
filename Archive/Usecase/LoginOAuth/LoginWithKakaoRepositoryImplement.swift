//
//  LoginWithKakaoRepositoryImplement.swift
//  Archive
//
//  Created by hanwe on 2022/03/20.
//

import UIKit
import KakaoSDKAuth
import KakaoSDKUser
import Moya
import SwiftyJSON
import RxSwift


class LoginWithKakaoRepositoryImplement: NSObject {
    
    private let disposeBag: DisposeBag = DisposeBag()
    
    func isKakaotalkInstalled() -> Bool {
        print("ddd")
        print("dd? :\(UserApi.isKakaoTalkLoginAvailable())")
        return UserApi.isKakaoTalkLoginAvailable()
    }
    
    func signIn(completion: @escaping (Result<String, ArchiveError>) -> Void) {
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.loginWithKakaoTalk { oAuthToken, error in
                if let error = error {
                    completion(.failure(.init(from: .kakaoOAuth, code: (error as NSError).code, message: error.localizedDescription)))
                } else {
                    guard let accessToken = oAuthToken?.accessToken else { completion(.failure(.init(.kakaoIdTokenIsNull))) ; return }
                    completion(.success(accessToken))
                }
            }
        } else {
            completion(.failure(.init(.kakaoIsNotIntalled)))
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

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
    
    private func oAuthLogin(type: OAuthSignInType, accessToken: String) -> Observable<Result<String, ArchiveError>> {
        let provider = ArchiveProvider.shared.provider
        return provider.rx.request(.logInWithOAuth(logInType: type, token: accessToken), callbackQueue: DispatchQueue.global())
            .asObservable()
            .map { [weak self] result in
                if result.statusCode == 200 {
                    guard let header = result.response?.headers else { return .failure(.init(.responseHeaderIsNull))}
                    guard let loginToken = header["Authorization"] else { return .failure(.init(.responseHeaderIsNull))}
                    return .success(loginToken)
                } else {
                    return .failure(.init(from: .server, code: result.statusCode, message: "서버오류"))
                }
                
            }
            .catch { err in
                    .just(.failure(.init(from: .network, code: err.responseCode, message: err.archiveErrMsg)))
            }
    }
    
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
        return self.kakaoRepository.isExistEmailWithKakao(accessToken: accessToken)
    }
    
    func loginWithKakao(accessToken: String) -> Observable<Result<String, ArchiveError>> {
        return self.oAuthLogin(type: .kakao, accessToken: accessToken)
    }
    
    func isExistEmailWithApple(accessToken: String) -> Observable<Bool> {
        return self.appleRepository.isExistEmailWithApple(accessToken: accessToken)
    }
    
    func loginWithApple(accessToken: String) -> Observable<Result<String, ArchiveError>> {
        return self.oAuthLogin(type: .apple, accessToken: accessToken)
    }
    
}

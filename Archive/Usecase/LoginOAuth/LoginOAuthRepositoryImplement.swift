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
        return self.kakaoRepository.isExistEmailWithKakao(accessToken: accessToken)
    }
    
    func loginWithKakao(accessToken: String) -> Observable<Result<String, ArchiveError>> {
        let provider = ArchiveProvider.shared.provider
        return provider.rx.request(.loginWithKakao(kakaoAccessToken: accessToken), callbackQueue: DispatchQueue.global())
            .asObservable()
            .map { [weak self] result in
                if result.statusCode == 200 {
                    guard let header = result.response?.headers else { return .failure(.init(.responseHeaderIsNull))}
                    guard let loginToken = header["Authorization"] else { return .failure(.init(.responseHeaderIsNull))}
                    let pureLoginToken = loginToken.replacingOccurrences(of: "BEARER ", with: "", options: NSString.CompareOptions.literal, range: nil)
                    return .success(pureLoginToken)
                } else {
                    return .failure(.init(from: .server, code: result.statusCode, message: "서버오류"))
                }
                
            }
            .catch { err in
                    .just(.failure(.init(from: .network, code: (err as NSError).code, message: err.localizedDescription)))
            }
    }
    
}

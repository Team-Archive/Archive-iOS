//
//  LoginWithAppleRepositoryImplement.swift
//  Archive
//
//  Created by hanwe on 2022/03/20.
//

import AuthenticationServices
import RxSwift
import SwiftyJSON

class LoginWithAppleRepositoryImplement: NSObject {
    var completion: ((Result<String, ArchiveError>) -> Void)?
    
    private let disposeBag: DisposeBag = DisposeBag()
    
    func signIn(completion: @escaping (Result<String, ArchiveError>) -> Void) {
        self.completion = completion
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        
        let request = appleIDProvider.createRequest()
        request.requestedOperation = .operationLogin
        request.requestedScopes = [.fullName, .email]
        request.nonce = Util.randomNonceString()
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func isExistEmailWithApple(accessToken: String) -> Observable<Bool> {
        return Observable.create { [weak self] emitter in
            guard let email = self?.extractEmail(accessToken: accessToken) else {
                emitter.onNext(false)
                emitter.onCompleted()
                return Disposables.create()
            }
            
            let provider = ArchiveProvider.shared.provider
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
            
            return Disposables.create()
        }
    }
    
    private func extractEmail(accessToken: String) -> String? {
        var returnValue: String?
        let splited = accessToken.split(separator: ".")
        if splited.count != 3 {
            return returnValue
        }
        var payloadBase64: String = String(splited[1])
        if payloadBase64.hasSuffix("==") {
        } else if payloadBase64.hasSuffix("=") {
            payloadBase64 += "="
        } else {
            payloadBase64 += "=="
        }
        guard let decodedPayload = Data(base64Encoded: payloadBase64) else {
            return returnValue
        }
        guard let payloadJson: JSON = try? JSON.init(data: decodedPayload) else {
            return returnValue
        }

        returnValue = payloadJson["email"].stringValue
        if returnValue == "" {
            return nil
        } else {
            return returnValue
        }
    }
}

extension LoginWithAppleRepositoryImplement: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        let scene = UIApplication.shared.connectedScenes.first
        if let sd: SceneDelegate = (scene?.delegate as? SceneDelegate) {
            return sd.window ?? UIWindow()
        }
        return UIWindow()
    }
    
}

extension LoginWithAppleRepositoryImplement: ASAuthorizationControllerDelegate {
    // Apple ID 연동 성공 시
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            guard let tokenData: Data = appleIDCredential.identityToken else { self.completion?(.failure(.init(.tokenNotExsitAppleSignIn))) ; return }
            guard let token = String(data: tokenData, encoding: .ascii) else { self.completion?(.failure(.init(.tokenAsciiToStringFailAppleSignIn))) ; return }
            self.completion?(.success(token))
        default:
            self.completion?(.failure(.init(.unexpectedAppleSignIn)))
        }
    }
        
    // Apple ID 연동 실패 시
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        if (error as NSError).code != 1001 { // 사용자 취소
            self.completion?(.failure(ArchiveError.init(from: .appleOAuth, code: error.responseCode, message: error.archiveErrMsg)))
        }
    }
}

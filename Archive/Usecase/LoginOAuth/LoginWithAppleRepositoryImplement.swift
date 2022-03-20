//
//  LoginWithAppleRepositoryImplement.swift
//  Archive
//
//  Created by hanwe on 2022/03/20.
//

import AuthenticationServices

class LoginWithAppleRepositoryImplement: NSObject {
    var completion: ((Result<String, ArchiveError>) -> Void)?
    
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
        self.completion?(.failure(ArchiveError.init(from: .appleOAuth, code: error.toResponseCode(), message: error.localizedDescription)))
    }
}

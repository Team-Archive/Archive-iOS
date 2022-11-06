//
//  Util.swift
//  Archive
//
//  Created by hanwe on 2021/10/29.
//

import UIKit

class Util {
    static func moveToSetting() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: nil)
        }
    }
    
    static func openUseSafari(_ url: String) {
        if let url = URL(string: url) {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    static func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var nonce = ""
        var remainingLength = length
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                if random < charset.count {
                    nonce.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return nonce
    }
    
    static func base64Decode(_ encoded: String) -> Data? {
        if let decodedPayload = Data(base64Encoded: encoded) {
            return decodedPayload
        } else {
            let secondTryEncoded = encoded + "="
            if let decodedPayload = Data(base64Encoded: secondTryEncoded) {
                return decodedPayload
            } else {
                let thirdTryEncoded = secondTryEncoded + "="
                if let decodedPayload = Data(base64Encoded: thirdTryEncoded) {
                    return decodedPayload
                } else {
                    return nil
                }
            }
        }
    }
    

}

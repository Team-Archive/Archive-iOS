//
//  AppDelegate.swift
//  Archive
//
//  Created by TTOzzi on 2021/09/30.
//

import UIKit
import Firebase
import KakaoSDKAuth
import KakaoSDKCommon

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupNavigationBarGlobalAppearance()
        FirebaseApp.configure()
        KakaoSDK.initSDK(appKey: CommonDefine.kakaoAppKey)
        return true
    }
    
    
    private func setupNavigationBarGlobalAppearance() {
        UINavigationBar.appearance().barTintColor = .white
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().backIndicatorImage = Gen.Images.back.image
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = Gen.Images.back.image
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffset(horizontal: .zero, vertical: -100), for: .default)
        UIBarButtonItem.appearance().tintColor = .black
    }
}


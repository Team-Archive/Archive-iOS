//
//  SceneDelegate.swift
//  Archive
//
//  Created by TTOzzi on 2021/09/30.
//

import UIKit
import RxFlow
import KakaoSDKAuth

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private let coordinator = FlowCoordinator()
    var appFlow: AppFlow!
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            self.window = window
            let appFlow = AppFlow(rootWindow: window)
            coordinator.coordinate(flow: appFlow, with: AppStepper())
            self.window?.makeKeyAndVisible()
        }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            if AuthApi.isKakaoTalkLoginUrl(url) {
                _ = AuthController.handleOpenUrl(url: url)
            }
        }
    }
}

//
//  AppDelegate.swift
//  Archive
//
//  Created by TTOzzi on 2021/09/30.
//

import UIKit
import Firebase
import FirebaseMessaging
import UserNotifications

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupNavigationBarGlobalAppearance()
        FirebaseApp.configure()
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization( options: authOptions, completionHandler: {_, _ in })
        application.registerForRemoteNotifications()
               
        Messaging.messaging().delegate = self
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM registration token: \(error)")
            }
            else if let token = token {
                print("FCM registration token: \(token)")
            }
        }
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

extension AppDelegate: UNUserNotificationCenterDelegate {

    // 푸시알림이 수신되었을 때 수행되는 메소드
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("메시지 수신")
        completionHandler([.alert, .badge, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        completionHandler()
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("파이어베이스 토큰: \(fcmToken)")
    }
}

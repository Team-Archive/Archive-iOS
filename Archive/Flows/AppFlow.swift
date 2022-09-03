//
//  AppFlow.swift
//  Archive
//
//  Created by TTOzzi on 2021/10/14.
//

import UIKit
import RxSwift
import RxRelay
import RxFlow

final class AppFlow: Flow {
    
    private let rootWindow: UIWindow
    
    var root: Presentable {
        return self.rootWindow
    }
    
    private lazy var rootViewController: UINavigationController = {
        let viewController = UINavigationController()
        viewController.setNavigationBarHidden(true, animated: false)
        return viewController
    }()
    
    init(rootWindow: UIWindow) {
        self.rootWindow = rootWindow
    }
    
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? ArchiveStep else {
            return .none
        }
        
        switch step {
        case .splashIsRequired:
            return navigationToSplashScreen()
        case .onboardingIsComplete:
            return navigationToMainScreen()
        case .logout:
            return navigationToOnboardingScreen()
        case .splashIsComplete(let isLoggedIn):
            if isLoggedIn {
                LikeManager.shared.refreshMyLikeList()
                return navigationToMainScreen()
            } else {
                return navigationToOnboardingScreen()
            }
        default:
            return .none
        }
    }
    
    private func navigationToSplashScreen() -> FlowContributors {
        let splashFlow = SplashFlow()
        Flows.use(splashFlow, when: Flows.ExecuteStrategy.ready, block: { [weak self] root in
            self?.rootWindow.rootViewController = root
            self?.rootWindow.makeKeyAndVisible()
        })
        
        return .one(flowContributor: .contribute(withNextPresentable: splashFlow,
                                                 withNextStepper: OneStepper(withSingleStep: ArchiveStep.splashIsRequired),
                                                 allowStepWhenNotPresented: false,
                                                 allowStepWhenDismissed: false))
    }
    
    private func navigationToOnboardingScreen() -> FlowContributors {
        let onboardingFlow = OnboardingFlow()
        Flows.use(onboardingFlow, when: Flows.ExecuteStrategy.ready, block: { [weak self] root in
            self?.rootWindow.rootViewController = root
            self?.rootWindow.makeKeyAndVisible()
        })
        
        return .one(flowContributor: .contribute(withNextPresentable: onboardingFlow,
                                                 withNextStepper: OneStepper(withSingleStep: ArchiveStep.signInIsRequired),
                                                 allowStepWhenNotPresented: false,
                                                 allowStepWhenDismissed: false))
    }
    
    private func navigationToMainScreen() -> FlowContributors {

        let mainFlow = MainFlow()
        Flows.use(mainFlow, when: Flows.ExecuteStrategy.ready, block: { [weak self] root in
            self?.rootWindow.rootViewController = root
            self?.rootWindow.makeKeyAndVisible()
        })
        
        return .one(flowContributor: .contribute(withNextPresentable: mainFlow,
                                                 withNextStepper: OneStepper(withSingleStep: ArchiveStep.mainIsRequired),
                                                 allowStepWhenNotPresented: false,
                                                 allowStepWhenDismissed: false))
    }
}

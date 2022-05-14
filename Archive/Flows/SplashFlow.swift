//
//  SplashFlow.swift
//  Archive
//
//  Created by hanwe on 2022/05/14.
//

import UIKit
import RxFlow

final class SplashFlow: Flow {
    
    // MARK: private property
    
    private lazy var rootViewController: UINavigationController = {
        let viewController = UINavigationController()
        return viewController
    }()
    
    // MARK: property
    
    var root: Presentable {
        return rootViewController
    }
    
    // MARK: lifeCycle
    
    // MARK: private func
    
    private func navigationToSplashScreen() -> FlowContributors {
        let reactor: MainSplashReactor = MainSplashReactor(repository: LoginAccessTokenRepositoryImplement())
        let splashViewController: MainSplashViewController = MainSplashViewController(reactor: reactor)
        rootViewController.pushViewController(splashViewController, animated: false)
        return .one(flowContributor: .contribute(withNextPresentable: splashViewController,
                                                 withNextStepper: reactor))
    }
    
    // MARK: func
    
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? ArchiveStep else { return .none }
        
        switch step {
        case .splashIsRequired:
            return navigationToSplashScreen()
        case .successAutoLoggedIn:
            return .end(forwardToParentFlowWithStep: ArchiveStep.splashIsComplete(isSuccessAutoLogin: true))
        case .failAutoLoggedIn:
            return .end(forwardToParentFlowWithStep: ArchiveStep.splashIsComplete(isSuccessAutoLogin: false))
        default:
            return .none
        }
    }

}
//            return .mainIsRequired
//        } else {
//            print("로그인 안됨")
//            return ArchiveStep.onboardingIsRequired

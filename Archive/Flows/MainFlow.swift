//
//  MainFlow.swift
//  Archive
//
//  Created by hanwe on 2022/05/14.
//

import UIKit
import RxFlow

final class MainFlow: Flow {
    
    // MARK: private property
    
    private let mainTabs: TabViewControllers
    private var mainTabBarContoller: MainTabBarViewController
    private var mainTabBarReactor: MainTabBarReactor
    
    private lazy var rootViewController: UINavigationController = {
        let viewController = UINavigationController()
        return viewController
    }()
    
    private let homeFlow: MainTabFlowProtocol = HomeFlow()
    private let myPageFlow: MainTabFlowProtocol = MyPageFlow()
    
    private(set) var currentTabFlow: Tab = .none
    
    private let presentedNavigationController: UINavigationController = UINavigationController()
    
    // MARK: property
    
    var root: Presentable {
        return rootViewController
    }
    
    // MARK: lifeCycle
    
    init() {
        self.mainTabs = MainFlow.makeMainTabs()
        let reactor: MainTabBarReactor = MainTabBarReactor()
        let mainTabBarController = MainTabBarViewController.init(reactor: reactor, tabViewControlers: self.mainTabs)
        self.mainTabBarContoller = mainTabBarController
        self.mainTabBarReactor = reactor
    }
    
    // MARK: private func
    
    private func setNavigationTitle(_ title: String) {
        self.rootViewController.navigationBar.topItem?.title = title
    }
    
    private static func makeMainTabs() -> TabViewControllers {
        let homeReactor: HomeReactor = HomeReactor()
        let homeViewController = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(identifier: HomeViewController.identifier) { coder in
            return HomeViewController(coder: coder, reactor: homeReactor)
        }
        homeViewController.tabBarItem = UITabBarItem(title: "homeTest", image: Gen.Images.btnApple.image, selectedImage: Gen.Images.btnApple.image)
        
        let myPageReactor: MyPageReactor = MyPageReactor(model: MyPageModel(cardCount: 0))
        let myPageViewController = UIStoryboard(name: "MyPage", bundle: nil).instantiateViewController(identifier: MyPageViewController.identifier) { coder in
            return MyPageViewController(coder: coder, reactor: myPageReactor)
        }
        myPageViewController.tabBarItem = UITabBarItem(title: "myPageTest", image: Gen.Images.btnApple.image, selectedImage: Gen.Images.btnApple.image)
        
        return TabViewControllers(homeViewController: homeViewController,
                                  homeStepper: homeReactor,
                                  myPageViewController: myPageViewController,
                                  myPageStepper: myPageReactor)
    }
    
    private func navigationToMainTabBarScreen(isRequiredPolicyAgree: Bool) -> FlowContributors {
        rootViewController.pushViewController(self.mainTabBarContoller, animated: false)
        if isRequiredPolicyAgree {
            print("present Policy Agree")
        }
        return .one(flowContributor: .contribute(withNextPresentable: self.mainTabBarContoller,
                                                 withNextStepper: self.mainTabBarReactor))
    }
    
    private func startTabFlow(new: Tab) -> FlowContributors {
        removeAllNavigationItems()
        switch new {
        case .home:
            self.homeFlow.rootViewController = self.rootViewController
            self.homeFlow.makeNavigationItems()
            return .one(flowContributor: .contribute(withNextPresentable: self.homeFlow, withNextStepper: self.mainTabs.homeStepper))
        case .myPage:
            self.myPageFlow.rootViewController = self.rootViewController
            self.myPageFlow.makeNavigationItems()
            return .one(flowContributor: .contribute(withNextPresentable: self.myPageFlow, withNextStepper: self.mainTabs.myPageStepper))
        case .none:
            return .none
        }
    }
    
    private func endTabFlow(current: Tab) {
        switch current {
        case .home:
            ((self.mainTabs.homeStepper) as? MainTabStepperProtocol)?.runReturnEndFlow()
        case .myPage:
            ((self.mainTabs.myPageStepper) as? MainTabStepperProtocol)?.runReturnEndFlow()
        case .none:
            break
        }
    }
    
    private func removeAllNavigationItems() {
        self.rootViewController.navigationBar.topItem?.leftBarButtonItems = nil
        self.rootViewController.navigationBar.topItem?.rightBarButtonItems = nil
    }
    
    // MARK: func
    
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? ArchiveStep else { return .none }
        switch step {
        default:
            return .none
        }
    }

}

protocol MainTabStepperProtocol {
    func runReturnEndFlow()
}

protocol MainTabFlowProtocol: Flow {
    var rootViewController: UINavigationController? { get set }
    func makeNavigationItems()
}

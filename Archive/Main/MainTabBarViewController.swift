//
//  MainTabBarViewController.swift
//  Archive
//
//  Created by hanwe on 2022/05/14.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit

class MainTabBarViewController: UITabBarController, View {
    
    // MARK: outlet
    
    // MARK: private property
    
    private weak var tabViewControllers: TabViewControllers?
    
    // MARK: property
    
    var disposeBag = DisposeBag()
    weak var targetView: UIView?
    
    private(set) var currentTab: Tab = .none {
        didSet {
            self.reactor?.action.onNext(.moveTo(currentTab))
            switch currentTab {
            case .none:
                self.currentSelectedMajorTabViewController = nil
            case .home:
                self.currentSelectedMajorTabViewController = self.tabViewControllers?.homeViewController
            case .record:
                break
            case .community:
                self.currentSelectedMajorTabViewController = self.tabViewControllers?.communityViewController
            case .myPage:
                self.currentSelectedMajorTabViewController = self.tabViewControllers?.myPageViewController
            }
        }
    }
    
    weak var currentSelectedMajorTabViewController: MajorTabViewController?
    
    // MARK: lifeCycle
    
    init(reactor: MainTabBarReactor, tabViewControlers: TabViewControllers) {
        self.tabViewControllers = tabViewControlers
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTabs()
        self.delegate = self
        initUI()
        self.targetView = self.view
    }
    
    func bind(reactor: MainTabBarReactor) {
        
    }
    
    // MARK: private func
    
    private func setTabs() {
        var controllers: [UIViewController] = []
        guard let tabs = self.tabViewControllers else { return }
        controllers.append(tabs.homeViewController)
        controllers.append(tabs.dummyRecordViewController)
        controllers.append(tabs.communityViewController)
        controllers.append(tabs.myPageViewController)
        self.viewControllers = controllers
        DispatchQueue.global().async { [weak self] in // 타이밍 이슈로 인해.. TODO: 해결법 찾아보기
            usleep(5 * 100 * 1000)
            DispatchQueue.main.async { [weak self] in
                self?.reactor?.action.onNext(.moveTo(.home))
//                self?.tabViewControllers?.homeViewController.appInit()
            }
        }
    }
    
    private func initUI() {
        self.tabBar.tintColor = Gen.Colors.black.color
    }
    
    // MARK: func
    
    func moveTabTo(_ tab: Tab) {
        self.currentSelectedMajorTabViewController?.willUnselected()
        switch tab {
        case .none:
            break
        case .home:
            self.tabViewControllers?.homeViewController.willTabSeleted()
            self.selectedIndex = tab.rawValue - 1
            self.currentTab = tab
            self.tabViewControllers?.homeViewController.didTabSeleted()
        case .record:
            break
        case .community:
            self.tabViewControllers?.communityViewController.willTabSeleted()
            self.selectedIndex = tab.rawValue - 1
            self.currentTab = tab
            self.tabViewControllers?.communityViewController.didTabSeleted()
        case .myPage:
            self.tabViewControllers?.myPageViewController.willTabSeleted()
            self.selectedIndex = tab.rawValue - 1
            self.currentTab = tab
            self.tabViewControllers?.myPageViewController.didTabSeleted()
        }
    }
    
    // MARK: action

    
    
}

extension MainTabBarViewController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        self.currentSelectedMajorTabViewController?.willUnselected()
        switch viewController {
        case self.tabViewControllers?.homeViewController:
            self.tabViewControllers?.homeViewController.willTabSeleted()
        case self.tabViewControllers?.communityViewController:
            self.tabViewControllers?.communityViewController.willTabSeleted()
        case self.tabViewControllers?.dummyRecordViewController:
            self.reactor?.action.onNext(.moveTo(.record))
            return false
        case self.tabViewControllers?.myPageViewController:
            self.tabViewControllers?.myPageViewController.willTabSeleted()
        default:
            print("selected unkownTab")
        }
        return true
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        switch viewController {
        case self.tabViewControllers?.homeViewController:
            if self.currentTab != .home {
                self.currentTab = .home
            }
            self.tabViewControllers?.homeViewController.didTabSeleted()
        case self.tabViewControllers?.communityViewController:
            if self.currentTab != .community {
                self.currentTab = .community
            }
            self.tabViewControllers?.communityViewController.didTabSeleted()
        case self.tabViewControllers?.myPageViewController:
            if self.currentTab != .myPage {
                self.currentTab = .myPage
            }
            self.tabViewControllers?.myPageViewController.didTabSeleted()
        default:
            print("selected unkownTab")
        }
    }
}

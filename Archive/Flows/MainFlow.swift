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
    private let communityFlow: MainTabFlowProtocol = CommunityFlow()
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
        let homeReactor: HomeReactor = HomeReactor(myArchiveRepository: MyArchiveRepositoryImplement(), detailRepository: DetailRepositoryImplement())
        let homeViewController = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(identifier: HomeViewController.identifier) { coder in
            return HomeViewController(coder: coder, reactor: homeReactor)
        }
        homeViewController.tabBarItem = UITabBarItem(title: "나의 관람", image: Gen.Images.homeOff.image, selectedImage: Gen.Images.homeOn.image)
        
        let dummyRecordViewController = DummyRecordViewController()
        dummyRecordViewController.tabBarItem = UITabBarItem(title: "전시 기록", image: Gen.Images.addArchvieOff.image, selectedImage: Gen.Images.addArchvieOn.image)
        
        let communityReactor: CommunityReactor = CommunityReactor(repository: CommunityRepositoryImplement(),
                                                                  bannerRepository: BannerRepositoryImplement(),
                                                                  detailRepository: DetailRepositoryImplement(),
                                                                  reportRepository: ReportRepositoryImplement())
        let communityViewController = CommunityViewController(reactor: communityReactor)
        communityViewController.tabBarItem = UITabBarItem(title: "전시 소통", image: Gen.Images.communityOff.image, selectedImage: Gen.Images.communityOn.image)
        
        
        let myPageReactor: MyPageReactor = MyPageReactor(repository: MyPageRepositoryImplement(),
                                                         myLikeRepository: MyLikeRepositoryImplement(),
                                                         detailRepository: DetailRepositoryImplement())
        let myPageViewController = MyPageViewController(reactor: myPageReactor)
        myPageViewController.tabBarItem = UITabBarItem(title: "나의 정보", image: Gen.Images.myPageOff.image, selectedImage: Gen.Images.myPageOn.image)
        
        return TabViewControllers(homeViewController: homeViewController,
                                  homeStepper: homeReactor,
                                  dummyRecordViewController: dummyRecordViewController,
                                  communityViewController: communityViewController,
                                  communityStepper: communityReactor,
                                  myPageViewController: myPageViewController,
                                  myPageStepper: myPageReactor)
    }
    
    private func navigationToMainTabBarScreen(isTempPw: Bool) -> FlowContributors {
        rootViewController.pushViewController(
            viewController: self.mainTabBarContoller,
            animated: false,
            completion: { [weak self] in
                if isTempPw {
                    self?.mainTabBarContoller.showChangeTempPasswordView()
                }
            })
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
        case .record:
            return .none
        case .community:
            self.communityFlow.rootViewController = self.rootViewController
            self.communityFlow.makeNavigationItems()
            return .one(flowContributor: .contribute(withNextPresentable: self.communityFlow, withNextStepper: self.mainTabs.communityStepper))
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
        case .record:
            break
        case .community:
            ((self.mainTabs.communityStepper) as? MainTabStepperProtocol)?.runReturnEndFlow()
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
    
    private func moveToRegistFlow() -> FlowContributors {
        let reactor = RegistReactor(uploadImageRepository: UploadImageRepositoryImplement())
        let vc: RegistViewController = RegistViewController(reactor: reactor)
        let navi = UINavigationController(rootViewController: vc)
        let registFlow = RegistFlow(rootViewController: navi, reacoter: reactor)
        navi.modalPresentationStyle = .fullScreen
        self.rootViewController.present(navi, animated: true)
        return .one(flowContributor: .contribute(withNextPresentable: registFlow,
                                                 withNextStepper: reactor))
    }
    
    // MARK: func
    
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? ArchiveStep else { return .none }
        switch step {
        case .mainIsRequired(let isTempPw):
            return navigationToMainTabBarScreen(isTempPw: isTempPw)
        case .homeIsRequired:
            if self.currentTabFlow != .home {
                print("homeIsRequired")
                endTabFlow(current: self.currentTabFlow)
                self.currentTabFlow = .home
                return startTabFlow(new: .home)
            } else {
                return .none
            }
        case .registIsRequired:
            GAModule.sendEventLogToGA(.startRegistArchive)
            return moveToRegistFlow()
        case .communityIsRequired:
            if self.currentTabFlow != .community {
                print("communityIsRequired")
                endTabFlow(current: self.currentTabFlow)
                self.currentTabFlow = .community
                return startTabFlow(new: .community)
            } else {
                return .none
            }
        case .communityIrRequiredFromCode:
            if self.currentTabFlow != .community {
                print("communityIsRequired")
                endTabFlow(current: self.currentTabFlow)
                self.currentTabFlow = .community
                mainTabBarContoller.moveTabTo(.community)
                return startTabFlow(new: .community)
            } else {
                return .none
            }
        case .myPageIsRequired:
            if self.currentTabFlow != .myPage {
                print("myPageIsRequired")
                endTabFlow(current: self.currentTabFlow)
                self.currentTabFlow = .myPage
                return startTabFlow(new: .myPage)
            } else {
                return .none
            }
        case .logout:
            return .end(forwardToParentFlowWithStep: ArchiveStep.logout)
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

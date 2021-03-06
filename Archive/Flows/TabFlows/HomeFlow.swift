//
//  HomeFlow.swift
//  Archive
//
//  Created by hanwe on 2021/12/10.
//

import UIKit
import RxFlow

class HomeFlow: Flow, MainTabFlowProtocol {
    
    private enum Constants {
        static let HomeStoryBoardName = "Home"
        static let HomeNavigationTitle = ""
        static let DetailStoryBoardName = "Detail"
        static let DetailNavigationTitle = "나의 아카이브"
        static let MyPageStoryBoardName = "MyPage"
        static let LoginInfoNavigationTitle = "로그인 정보"
        static let WithdrawalNavigationTitle = "회원탈퇴"
    }
    
    // MARK: private property
    
    private let homeStoryBoard = UIStoryboard(name: Constants.HomeStoryBoardName, bundle: nil)
    private let detailStoryBoard = UIStoryboard(name: Constants.DetailStoryBoardName, bundle: nil)
    private let myPageStoryBoard = UIStoryboard(name: Constants.MyPageStoryBoardName, bundle: nil)
    
    private weak var homeViewControllerPtr: HomeViewController?
    private weak var recordViewController: RecordViewController?
    private weak var editEmotionViewController: EmotionSelectViewController?
    
    // MARK: internal property
    
    var root: Presentable {
        return rootViewController ?? UINavigationController()
    }
    
    weak var rootViewController: UINavigationController?
    
    // MARK: lifeCycle
    
    // MARK: private function
    
    // MARK: internal function
    
    func makeNavigationItems() {
        let logoImage = Gen.Images.logo.image
        let logoImageView = UIImageView.init(image: logoImage)
        logoImageView.frame = CGRect(x: -40, y: 0, width: 108, height: 28)
        logoImageView.contentMode = .scaleAspectFit
        let imageItem = UIBarButtonItem.init(customView: logoImageView)
        let negativeSpacer = UIBarButtonItem.init(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        negativeSpacer.width = -25
        
        let leftItems: [UIBarButtonItem] = [negativeSpacer, imageItem]
        self.rootViewController?.navigationBar.topItem?.leftBarButtonItems = leftItems
    }
    
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? ArchiveStep else { return .none }
        switch step {
        case .detailIsRequired(let info, let index):
            GAModule.sendEventLogToGA(.showDetail)
            navigationToDetailScreen(infoData: info, index: index)
            return .none
        case .myPageIsRequired:
            return navigationToMyPageScreen()
        case .loginInfomationIsRequired(let type, let email, let cardCnt):
            return navigationToLoginInformationScreen(type: type, eMail: email ?? "", cardCnt: cardCnt)
        case .withdrawalIsRequired(let cnt):
            return navigationToWithdrawalScreen(cardCount: cnt)
        case .logout:
            return .end(forwardToParentFlowWithStep: ArchiveStep.logout)
        default:
            return .none
        }
    }
    
    private func navigationToDetailScreen(infoData: ArchiveDetailInfo, index: Int) {
        let reactor = DetailReactor(recordData: infoData, index: index)
        let detailViewController: DetailViewController = detailStoryBoard.instantiateViewController(identifier: DetailViewController.identifier) { corder in
            return DetailViewController(coder: corder, reactor: reactor)
        }
        detailViewController.title = Constants.DetailNavigationTitle
        detailViewController.delegate = self
        let navi = UINavigationController(rootViewController: detailViewController)
        navi.modalPresentationStyle = .fullScreen
        self.rootViewController?.present(navi, animated: true)
    }
    
    private func navigationToMyPageScreen() -> FlowContributors {
        let reactor = MyPageReactor()
        let myPageViewController = MyPageViewController(reactor: reactor)
        rootViewController?.pushViewController(myPageViewController, animated: true)
        return .one(flowContributor: .contribute(withNextPresentable: myPageViewController,
                                                 withNextStepper: reactor))
    }
    
    private func navigationToLoginInformationScreen(type: LoginType, eMail: String, cardCnt: Int) -> FlowContributors {
        let model: LoginInformationModel = LoginInformationModel(email: eMail, cardCount: cardCnt)
        let reactor = LoginInformationReactor(model: model, type: type, validator: Validator(), findPasswordUsecase: FindPasswordUsecase(repository: FindPasswordRepositoryImplement()))
        let loginInfoViewController: LoginInformationViewController = myPageStoryBoard.instantiateViewController(identifier: LoginInformationViewController.identifier) { corder in
            return LoginInformationViewController(coder: corder, reactor: reactor)
        }
        loginInfoViewController.title = Constants.LoginInfoNavigationTitle
        rootViewController?.pushViewController(loginInfoViewController, animated: true)
        return .one(flowContributor: .contribute(withNextPresentable: loginInfoViewController, withNextStepper: reactor))
    }
    
    private func navigationToWithdrawalScreen(cardCount: Int) -> FlowContributors {
        let model: WithdrawalModel = WithdrawalModel(cardCount: cardCount)
        let reactor = WithdrawalReactor(model: model)
        let withdrawalViewController: WithdrawalViewController = myPageStoryBoard.instantiateViewController(identifier: WithdrawalViewController.identifier) { corder in
            return WithdrawalViewController(coder: corder, reactor: reactor)
        }
        withdrawalViewController.title = Constants.WithdrawalNavigationTitle
        rootViewController?.pushViewController(withdrawalViewController, animated: true)
        return .one(flowContributor: .contribute(withNextPresentable: withdrawalViewController, withNextStepper: reactor))
    }
    
}

extension HomeFlow: DetailViewControllerDelegate {
    func willDeletedArchive(index: Int) {
        self.homeViewControllerPtr?.willDeletedIndex(index)
    }
    
    func deletedArchive() {
        self.homeViewControllerPtr?.reactor?.action.onNext(.refreshMyArchives)
    }
    
}

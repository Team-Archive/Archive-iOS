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
        static let LoginInfoNavigationTitle = "로그인 정보"
        static let WithdrawalNavigationTitle = "회원탈퇴"
    }
    
    // MARK: private property
    
    private let homeStoryBoard = UIStoryboard(name: Constants.HomeStoryBoardName, bundle: nil)
    private let detailStoryBoard = UIStoryboard(name: Constants.DetailStoryBoardName, bundle: nil)
    
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
        self.rootViewController?.navigationBar.topItem?.title = ""
    }
    
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? ArchiveStep else { return .none }
        switch step {
        case .detailIsRequired(let info, let index):
            GAModule.sendEventLogToGA(.showDetail)
            navigationToDetailScreen(infoData: info, index: index)
            return .none
        case .logout:
            return .end(forwardToParentFlowWithStep: ArchiveStep.logout)
        case .homeIsComplete:
            return .end(forwardToParentFlowWithStep: ArchiveStep.homeIsComplete)
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
    
}

extension HomeFlow: DetailViewControllerDelegate {
    func willDeletedArchive(index: Int) {
        self.homeViewControllerPtr?.willDeletedIndex(index)
    }
    
    func deletedArchive() {
        self.homeViewControllerPtr?.reactor?.action.onNext(.refreshMyArchives)
    }
    
}

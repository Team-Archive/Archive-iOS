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
        static let DetailStoryBoardName = "Detail"
    }
    
    // MARK: private property
    
    private let detailStoryBoard = UIStoryboard(name: Constants.DetailStoryBoardName, bundle: nil)
    
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
        self.rootViewController?.navigationBar.topItem?.title = "ㅤ"
    }
    
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? ArchiveStep else { return .none }
        switch step {
        case .detailIsRequired(let info, let index, let isPublic):
            GAModule.sendEventLogToGA(.showDetail)
            navigationToDetailScreen(infoData: info, index: index, isPublic: isPublic)
            return .none
        case .logout:
            return .end(forwardToParentFlowWithStep: ArchiveStep.logout)
        case .homeIsComplete:
            return .end(forwardToParentFlowWithStep: ArchiveStep.homeIsComplete)
        default:
            return .none
        }
    }
    
    private func navigationToDetailScreen(infoData: ArchiveDetailInfo, index: Int, isPublic: Bool) {
        let reactor = DetailReactor(recordData: infoData, index: index, isPublic: isPublic, archiveEditRepository: ArchiveEditRepositoryImplement())
        let detailViewController: DetailViewController = detailStoryBoard.instantiateViewController(identifier: DetailViewController.identifier) { corder in
            return DetailViewController(coder: corder, reactor: reactor)
        }
        let navi = UINavigationController(rootViewController: detailViewController)
        navi.modalPresentationStyle = .fullScreen
        self.rootViewController?.present(navi, animated: true)
    }
    
}

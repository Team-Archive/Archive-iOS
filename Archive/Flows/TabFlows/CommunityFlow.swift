//
//  CommunityFlow.swift
//  Archive
//
//  Created by hanwe on 2022/05/14.
//

import RxFlow

class CommunityFlow: Flow, MainTabFlowProtocol {
    
    private enum Constants {
    }
    
    // MARK: private property
    
    // MARK: internal property
    
    var root: Presentable {
        return rootViewController ?? UINavigationController()
    }
    
    weak var rootViewController: UINavigationController?
    
    // MARK: lifeCycle
    
    // MARK: private function
    
    private func navigationToDetailScreen(infoData: ArchiveDetailInfo, index: Int, reactor: CommunityReactor) {
        let vc = CommunityDetailViewController(reactor: reactor)
        reactor.action.onNext(.spreadDetailData(infoData: infoData, index: index))
        let navi = UINavigationController(rootViewController: vc)
        navi.modalPresentationStyle = .fullScreen
        self.rootViewController?.present(navi, animated: true)
    }
    
    // MARK: internal function
    
    func makeNavigationItems() {
        
    }
    
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? ArchiveStep else { return .none }
        switch step {
        case .communityDetailIsRequired(let data, let index, let reactor):
            navigationToDetailScreen(infoData: data, index: index, reactor: reactor)
            return .none
        default:
            return .none
        }
    }
    
}

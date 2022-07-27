//
//  MyPageFlow.swift
//  Archive
//
//  Created by hanwe on 2022/05/14.
//

import RxFlow

class MyPageFlow: Flow, MainTabFlowProtocol {
    
    
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
    
    private func navigationToWebView(url: URL, title: String) {
        let vc = CommonWebViewController(url: url, title: title)
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
        case .homeIsRequired:
            return .none
        case .openUrlIsRequired(let url, let title):
            navigationToWebView(url: url, title: title)
            return .none
        default:
            return .none
        }
    }
    
}

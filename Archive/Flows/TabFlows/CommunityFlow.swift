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
    
    private func navigationToBannerImageDetail(url: URL) {
        let vc = FullImageViewController(url: url)
        let navi = UINavigationController(rootViewController: vc)
        navi.modalPresentationStyle = .fullScreen
        self.rootViewController?.present(navi, animated: true)
    }
    
    private func navigationToBannerWebViewDetail(url: URL, title: String) {
        let vc = CommonWebViewController(url: url, title: title)
        let navi = UINavigationController(rootViewController: vc)
        navi.modalPresentationStyle = .fullScreen
        self.rootViewController?.present(navi, animated: true)
    }
    
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
        case .communityDetailIsRequired(let data, let index, let reactor):
            navigationToDetailScreen(infoData: data, index: index, reactor: reactor)
            return .none
        case .bannerImageIsRequired(let imageUrl):
            navigationToBannerImageDetail(url: imageUrl)
            return .none
        case .openUrlIsRequired(let url, let title):
            navigationToBannerWebViewDetail(url: url, title: title)
            return .none
        case .communityIsComplete:
            return .end(forwardToParentFlowWithStep: ArchiveStep.communityIsComplete)
        default:
            return .none
        }
    }
    
}

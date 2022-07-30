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
    
    private func navigationToLoginInformationScreen(info: MyLoginInfo, cardCnt: Int) {
        let reactor = LoginInformationReactor(loginInfo: info,
                                              archiveCnt: cardCnt,
                                              validator: Validator(),
                                              findPasswordUsecase: FindPasswordUsecase(repository: FindPasswordRepositoryImplement()))
        let loginInfoViewController: LoginInformationViewController = UIStoryboard(name: "MyPage", bundle: nil).instantiateViewController(identifier: LoginInformationViewController.identifier) { corder in
            return LoginInformationViewController(coder: corder, reactor: reactor)
        }
        loginInfoViewController.title = "로그인 정보"
        rootViewController?.pushViewController(loginInfoViewController, animated: true)
    }
    
    
    
//    private func navigationToWithdrawalScreen(cardCount: Int) -> FlowContributors {
//        let model: WithdrawalModel = WithdrawalModel(cardCount: cardCount)
//        let reactor = WithdrawalReactor(model: model)
//        let withdrawalViewController: WithdrawalViewController = myPageStoryBoard.instantiateViewController(identifier: WithdrawalViewController.identifier) { corder in
//            return WithdrawalViewController(coder: corder, reactor: reactor)
//        }
//        withdrawalViewController.title = Constants.WithdrawalNavigationTitle
//        rootViewController?.pushViewController(withdrawalViewController, animated: true)
//        return .one(flowContributor: .contribute(withNextPresentable: withdrawalViewController, withNextStepper: reactor))
//    }
    
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
        case .loginInfomationIsRequired(let info, let archiveCnt):
            navigationToLoginInformationScreen(info: info, cardCnt: archiveCnt)
            return .none
        default:
            return .none
        }
    }
    
}

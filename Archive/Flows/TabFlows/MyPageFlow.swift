//
//  MyPageFlow.swift
//  Archive
//
//  Created by hanwe on 2022/05/14.
//

import RxFlow
import RxRelay

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
    
    private func navigationToLoginInformationScreen(stepper: PublishRelay<Step>, info: MyLoginInfo, cardCnt: Int) {
        let reactor = LoginInformationReactor(stepper: stepper, loginInfo: info,
                                              archiveCnt: cardCnt,
                                              validator: Validator(),
                                              findPasswordUsecase: FindPasswordUsecase(repository: FindPasswordRepositoryImplement()))
        let loginInfoViewController: LoginInformationViewController = UIStoryboard(name: "MyPage", bundle: nil).instantiateViewController(identifier: LoginInformationViewController.identifier) { corder in
            return LoginInformationViewController(coder: corder, reactor: reactor)
        }
        loginInfoViewController.title = "로그인 정보"
        rootViewController?.pushViewController(loginInfoViewController, animated: true)
    }
    
    private func navigationToWithdrawalScreen(reactor: LoginInformationReactor) {
        let withdrawalViewController: WithdrawalViewController = UIStoryboard(name: "MyPage", bundle: nil).instantiateViewController(identifier: WithdrawalViewController.identifier) { corder in
            return WithdrawalViewController(coder: corder, reactor: reactor)
        }
        withdrawalViewController.title = "회원탈퇴"
        rootViewController?.pushViewController(withdrawalViewController, animated: true)
    }
    
    private func navigationToMyLikeListScreen(reactor: MyPageReactor) {
        let vc = MyLikeListViewController(reactor: reactor)
        vc.title = "좋아요 한 전시기록"
        rootViewController?.pushViewController(vc, animated: true)
    }
    
    private func navigationToEditProfile(reactor: MyPageReactor) {
        let vc = EditProfileViewController(reactor: reactor)
        vc.title = "프로필 수정"
        rootViewController?.pushViewController(vc, animated: true)
    }
    
    private func navigationToMyLikeDetail(info: ArchiveDetailInfo) {
        let reactor = DetailReactor(recordData: info, index: 0)
        let detailViewController: DetailViewController = UIStoryboard(name: "Detail", bundle: nil).instantiateViewController(identifier: DetailViewController.identifier) { corder in
            return DetailViewController(coder: corder, reactor: reactor, type: .myLike)
        }
        let navi = UINavigationController(rootViewController: detailViewController)
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
        case .loginInfomationIsRequired(let stepper, let info, let archiveCnt):
            navigationToLoginInformationScreen(stepper: stepper, info: info, cardCnt: archiveCnt)
            return .none
        case .logout:
            return .end(forwardToParentFlowWithStep: ArchiveStep.logout)
        case .withdrawalIsRequired(let reactor):
            navigationToWithdrawalScreen(reactor: reactor)
            return .none
        case .myLikeListIsRequired(let reactor):
            navigationToMyLikeListScreen(reactor: reactor)
            return .none
        case .editProfileIsRequired(let reactor):
            navigationToEditProfile(reactor: reactor)
            return .none
        case .myPageIsComplete:
            return .end(forwardToParentFlowWithStep: ArchiveStep.myPageIsComplete)
        case .communityIsRequired:
            return .end(forwardToParentFlowWithStep: ArchiveStep.communityIsRequired)
        case .myLikeArchiveDetailIsRequired(let infoData):
            navigationToMyLikeDetail(info: infoData)
            return .none
        default:
            return .none
        }
    }
    
}

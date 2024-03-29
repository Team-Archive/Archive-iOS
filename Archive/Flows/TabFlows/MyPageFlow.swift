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
    
    private func navigationToLoginInformationScreen(stepper: PublishRelay<Step>, info: MyLoginInfo) {
        let reactor = LoginInformationReactor(stepper: stepper, loginInfo: info,
                                              archiveCnt: LogInManager.shared.myTotalArchiveCnt,
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
        GAModule.sendEventLogToGA(.showMyLikeList)
        let vc = MyLikeListViewController(reactor: reactor)
        vc.title = "좋아요 한 전시기록"
        rootViewController?.pushViewController(vc, animated: true)
    }
    
    private func navigationToEditProfile() -> FlowContributors {
        let reactor = EditProfileReactor(nickNameDuplicationRepository: NickNameDuplicationRepositoryImplement(),
                                         profileRepository: ProfileRepositoryImplement(),
                                         uploadImageRepository: UploadProfilePhotoImageRepositoryImplement())
        let vc = EditProfileViewController(reactor: reactor)
        vc.title = "프로필 수정"
        let editProfileFlow = EditProfileFlow(rootViewController: self.rootViewController ?? UINavigationController())
        rootViewController?.pushViewController(vc, animated: true)
        return .one(flowContributor: .contribute(withNextPresentable: editProfileFlow,
                                                 withNextStepper: reactor))
    }
    
    private func navigationToMyLikeDetail(info: ArchiveDetailInfo, isPublic: Bool) {
        let reactor = DetailReactor(recordData: info, index: 0, isPublic: isPublic, archiveEditRepository: ArchiveEditRepositoryImplement())
        let detailViewController: DetailViewController = UIStoryboard(name: "Detail", bundle: nil).instantiateViewController(identifier: DetailViewController.identifier) { corder in
            return DetailViewController(coder: corder, reactor: reactor, type: .myLike)
        }
        let navi = UINavigationController(rootViewController: detailViewController)
        navi.modalPresentationStyle = .fullScreen
        self.rootViewController?.present(navi, animated: true)
    }
    
    // MARK: internal function
    
    func makeNavigationItems() {
        self.rootViewController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.fonts(.subTitle),
            NSAttributedString.Key.foregroundColor: Gen.Colors.gray01.color
        ]
        self.rootViewController?.navigationBar.topItem?.leftBarButtonItems = nil
        self.rootViewController?.navigationBar.topItem?.title = "내 정보"
    }
    
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? ArchiveStep else { return .none }
        switch step {
        case .homeIsRequired:
            return .none
        case .openUrlIsRequired(let url, let title):
            navigationToWebView(url: url, title: title)
            return .none
        case .loginInfomationIsRequired(let stepper, let info):
            navigationToLoginInformationScreen(stepper: stepper, info: info)
            return .none
        case .logout:
            return .end(forwardToParentFlowWithStep: ArchiveStep.logout)
        case .withdrawalIsRequired(let reactor):
            navigationToWithdrawalScreen(reactor: reactor)
            return .none
        case .myLikeListIsRequired(let reactor):
            navigationToMyLikeListScreen(reactor: reactor)
            return .none
        case .editProfileIsRequired:
            return navigationToEditProfile()
        case .myPageIsComplete:
            return .end(forwardToParentFlowWithStep: ArchiveStep.myPageIsComplete)
        case .communityIrRequiredFromCode:
            return .end(forwardToParentFlowWithStep: ArchiveStep.communityIrRequiredFromCode)
        case .myLikeArchiveDetailIsRequired(let infoData):
            navigationToMyLikeDetail(info: infoData, isPublic: false)
            return .none
        case .editProfileIsComplete:
            return .none
        default:
            return .none
        }
    }
    
}

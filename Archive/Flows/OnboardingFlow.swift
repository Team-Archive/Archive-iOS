//
//  OnboardingFlow.swift
//  Archive
//
//  Created by TTOzzi on 2021/10/14.
//

import UIKit
import RxFlow

final class OnboardingFlow: Flow {
    
    private enum Constants {
        static let onboardingStoryBoardName = "Onboarding"
        static let signUpNavigationTitle = "회원가입"
    }
    
    var root: Presentable {
        return rootViewController
    }
    private lazy var rootViewController: UINavigationController = {
        let viewController = UINavigationController()
        return viewController
    }()
    private let onboardingStoryBoard = UIStoryboard(name: Constants.onboardingStoryBoardName, bundle: nil)
    private let validator = Validator()
    private lazy var signUpReactor = SignUpReactor(validator: validator)
    private lazy var signInReactor = SignInReactor(validator: validator, loginOAuthRepository: LoginOAuthRepositoryImplement())
    
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? ArchiveStep else { return .none }

        switch step {
        case .signInIsRequired:
            return navigationToSignInScreen()
        case .eMailSignIn(reactor: let reactor):
            return navigationToEmailSignIn(reactor: reactor)
        case .userIsSignedIn:
            return .end(forwardToParentFlowWithStep: ArchiveStep.onboardingIsComplete)
        case .termsAgreementIsRequired:
            return navigationToTermsAgreementScreen()
        case .emailInputRequired:
            return navigationToEmailInputScreen()
        case .passwordInputRequired:
            return navigationToPasswordInputScreen()
        case .userIsSignedUp:
            return navigationToSignUpCompletionScreen()
        case .signUpComplete:
            rootViewController.popToRootViewController(animated: true)
            return .none
        case .termsAgreeForOAuthRegist(let accessToken):
            return navigationToTermsAgreementForOAuthScreen(accessToken: accessToken)
        case .findPassword:
            return navigationToFindPasswordScreen()
        default:
            return .none
        }
    }
    
    private func navigationToSignInScreen() -> FlowContributors {
        let signInViewController = onboardingStoryBoard
            .instantiateViewController(identifier: SignInViewController.identifier) { coder in
                return SignInViewController(coder: coder, reactor: self.signInReactor)
            }
        rootViewController.pushViewController(signInViewController, animated: false)
        return .one(flowContributor: .contribute(withNextPresentable: signInViewController,
                                                 withNextStepper: signInReactor))
    }
    
    private func navigationToTermsAgreementScreen() -> FlowContributors {
        let termsAgreementViewController = onboardingStoryBoard
            .instantiateViewController(identifier: TermsAgreementViewController.identifier) { coder in
                return TermsAgreementViewController(coder: coder, reactor: self.signUpReactor)
            }
        termsAgreementViewController.title = Constants.signUpNavigationTitle
        rootViewController.pushViewController(termsAgreementViewController, animated: true)
        return .one(flowContributor: .contribute(withNextPresentable: termsAgreementViewController,
                                                 withNextStepper: signUpReactor))
    }
    
    private func navigationToEmailInputScreen() -> FlowContributors {
        let emailInputViewController = onboardingStoryBoard
            .instantiateViewController(identifier: EmailInputViewController.identifier) { coder in
                return EmailInputViewController(coder: coder, reactor: self.signUpReactor)
            }
        emailInputViewController.title = Constants.signUpNavigationTitle
        rootViewController.pushViewController(emailInputViewController, animated: true)
        return .one(flowContributor: .contribute(withNextPresentable: emailInputViewController,
                                                 withNextStepper: signUpReactor))
    }
    
    private func navigationToPasswordInputScreen() -> FlowContributors {
        let passwordInputViewController = onboardingStoryBoard
            .instantiateViewController(identifier: PasswordInputViewController.identifier) { coder in
                return PasswordInputViewController(coder: coder, reactor: self.signUpReactor)
            }
        passwordInputViewController.title = Constants.signUpNavigationTitle
        rootViewController.pushViewController(passwordInputViewController, animated: true)
        return .one(flowContributor: .contribute(withNextPresentable: passwordInputViewController,
                                                 withNextStepper: signUpReactor))
    }
    
    private func navigationToSignUpCompletionScreen() -> FlowContributors {
        let signUpCompletionViewController = onboardingStoryBoard
            .instantiateViewController(identifier: SignUpCompletionViewController.identifier) { coder in
                return SignUpCompletionViewController(coder: coder, reactor: self.signUpReactor)
            }
        rootViewController.pushViewController(signUpCompletionViewController, animated: true)
        return .one(flowContributor: .contribute(withNextPresentable: signUpCompletionViewController,
                                                 withNextStepper: signUpReactor))
    }
    
    private func navigationToEmailSignIn(reactor: SignInReactor) -> FlowContributors {
        let vc = onboardingStoryBoard
            .instantiateViewController(identifier: EmailSignInViewController.identifier) { coder in
                return EmailSignInViewController(coder: coder, reactor: reactor)
            }
        rootViewController.pushViewController(vc, animated: true)
        return .one(flowContributor: .contribute(withNextPresentable: vc,
                                                 withNextStepper: reactor))
    }
    
    private func navigationToTermsAgreementForOAuthScreen(accessToken: String) -> FlowContributors {
        let termsAgreementViewController = onboardingStoryBoard
            .instantiateViewController(identifier: TermsAgreementForOAuthViewController.identifier) { coder in
                return TermsAgreementForOAuthViewController(coder: coder, reactor: self.signUpReactor)
            }
        termsAgreementViewController.title = Constants.signUpNavigationTitle
        self.signUpReactor.kakaoAccessToken = accessToken
        rootViewController.pushViewController(termsAgreementViewController, animated: true)
        return .one(flowContributor: .contribute(withNextPresentable: termsAgreementViewController,
                                                 withNextStepper: signUpReactor))
    }
    
    private func navigationToFindPasswordScreen() -> FlowContributors {
        let findPasswordViewController = onboardingStoryBoard
            .instantiateViewController(identifier: FindPasswordViewController.identifier) { coder in
                return FindPasswordViewController(coder: coder, reactor: self.signInReactor)
            }
        rootViewController.pushViewController(findPasswordViewController, animated: true)
        return .one(flowContributor: .contribute(withNextPresentable: findPasswordViewController,
                                                 withNextStepper: signInReactor))
    }
}

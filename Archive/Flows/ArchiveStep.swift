//
//  ArchiveStep.swift
//  Archive
//
//  Created by TTOzzi on 2021/10/14.
//

import RxFlow
import RxRelay

enum ArchiveStep: Step {
    
    // Splash
    case splashIsRequired
    case successAutoLoggedIn
    case failAutoLoggedIn
    case splashIsComplete(isSuccessAutoLogin: Bool)
    
    // Onboarding
    case onboardingIsComplete(isTempPw: Bool)
    
    // SignIn
    case signInIsRequired
    case eMailSignIn(reactor: SignInReactor)
    case userIsSignedIn(isTempPw: Bool)
    case findPassword
    
    // SignUp
    case termsAgreementIsRequired
    case emailInputRequired
    case passwordInputRequired
    case userIsSignedUp
    case nicknameSignupIsRequired
    case signUpComplete
    case termsAgreeForOAuthRegist(accessToken: String, loginType: OAuthSignInType)
    
    // MainTab
    case mainIsRequired(isTempPw: Bool)
    
    // Home
    case homeIsRequired
    case homeIsComplete
    
    // Community
    case communityIsRequired
    case communityIsComplete
    case communityDetailIsRequired(data: ArchiveDetailInfo, currentIndex: Int, reactor: CommunityReactor)
    case communityIrRequiredFromCode
    case communityReportIsRequired(reactor: CommunityReactor)
    
    // MyPage
    case myPageIsRequired
    case loginInfomationIsRequired(stepper: PublishRelay<Step>, info: MyLoginInfo)
    case withdrawalIsRequired(reactor: LoginInformationReactor)
    case withdrawalIsComplete
    case logout
    case myPageIsComplete
    case myLikeListIsRequired(reactor: MyPageReactor)
    case myLikeArchiveDetailIsRequired(data: ArchiveDetailInfo)
    
    // Regist
    case registIsRequired
    case registUploadIsRequired
    case registUploadIsComplete
    case registCompleteIsRequired(thisMonthRegistCnt: Int)
    case registIsComplete
    
    // Detail
    case detailIsRequired(ArchiveDetailInfo, Int)
    
    // Edit Profile
    case editProfileIsRequired
    case editProfileIsComplete
    
    // 기타 등등
    case bannerImageIsRequired(imageUrl: URL)
    case openUrlIsRequired(url: URL, title: String)
}

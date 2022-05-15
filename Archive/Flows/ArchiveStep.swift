//
//  ArchiveStep.swift
//  Archive
//
//  Created by TTOzzi on 2021/10/14.
//

import RxFlow

enum ArchiveStep: Step {
    
    // Splash
    case splashIsRequired
    case successAutoLoggedIn
    case failAutoLoggedIn
    case splashIsComplete(isSuccessAutoLogin: Bool)
    
    // Onboarding
    case onboardingIsComplete
    
    // SignIn
    case signInIsRequired
    case eMailSignIn(reactor: SignInReactor)
    case userIsSignedIn
    case findPassword
    case changePasswordFromFindPassword
    
    // SignUp
    case termsAgreementIsRequired
    case emailInputRequired
    case passwordInputRequired
    case userIsSignedUp
    case signUpComplete
    case termsAgreeForOAuthRegist(accessToken: String, loginType: OAuthSignInType)
    
    // MainTab
    case mainIsRequired
    
    // Home
    case homeIsRequired
    case homeIsComplete
    
    // Community
    case communityIsRequired
    case communityIsComplete
    
    // MyPage
    case myPageIsRequired
    case loginInfomationIsRequired(LoginType, String?, Int)
    case withdrawalIsRequired(Int)
    case withdrawalIsComplete
    case logout
    case myPageIsComplete
    
    // Record
    case recordIsRequired
    case recordEmotionEditIsRequired(Emotion?)
    case recordEmotionEditIsComplete(Emotion)
    case recordImageSelectIsRequired(Emotion)
    case recordImageSelectIsComplete(UIImage, [UIImage])
    case recordUploadIsRequired(ContentsRecordModelData, UIImage, Emotion, [ImageInfo]?)
    case recordUploadIsComplete(UIImage, Emotion, ContentsRecordModelData)
    case recordComplete
    
    // Detail
    case detailIsRequired(ArchiveDetailInfo, Int)
    
}

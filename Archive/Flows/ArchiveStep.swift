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
    case communityDetailIsRequired(data: ArchiveDetailInfo, currentIndex: Int, reactor: CommunityReactor)
    
    // MyPage
    case myPageIsRequired
    case loginInfomationIsRequired(info: MyLoginInfo, archiveCnt: Int)
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
    case recordUploadCompleteDone // 업로드 완료화면 닫기
    case recordComplete
    case recordClose // 완료 안하고 닫기
    
    // Detail
    case detailIsRequired(ArchiveDetailInfo, Int)
    
    // 기타 등등
    case bannerImageIsRequired(imageUrl: URL)
    case openUrlIsRequired(url: URL, title: String)
}

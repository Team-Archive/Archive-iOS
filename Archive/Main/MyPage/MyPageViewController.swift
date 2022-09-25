//
//  MyPageViewController.swift
//  Archive
//
//  Created by hanwe on 2022/05/15.
//

import UIKit
import ReactorKit
import Then
import RxCocoa
import RxSwift
import Kingfisher

class MyPageViewController: UIViewController, View, ActivityIndicatorable {

    // MARK: private ui property
    
    private let mainBackgroundView = UIView().then {
        $0.backgroundColor = Gen.Colors.white.color
    }
    
    private let mainContentsView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private let scrollView = UIScrollView().then {
        $0.backgroundColor = .clear
        $0.delaysContentTouches = false
    }
    
    private let stackView = UIStackView().then {
        $0.backgroundColor = .clear
        $0.axis = .vertical
        $0.distribution = .fill
    }
    
    // profile
    
    private let myProfileContainerView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private let profileImageContainerView = UIView().then {
        $0.backgroundColor = .clear
        $0.layer.cornerRadius = 31
        $0.layer.masksToBounds = true
    }
    
    private let profileImageView = UIImageView().then {
        $0.backgroundColor = .clear
        $0.image = Gen.Images.userImagePlaceHolder.image
    }
    
    private let nameLabel = UILabel().then {
        $0.font = .fonts(.header3)
        $0.textColor = Gen.Colors.gray01.color
        $0.text = "test"
    }
    
    private lazy var modifyProfileBtn = UIButton().then {
        $0.titleLabel?.font = .fonts(.button)
        $0.setTitleAllState("프로필 수정")
        $0.setTitleColor(Gen.Colors.gray02.color, for: .normal)
        $0.setTitleColor(Gen.Colors.gray03.color, for: .highlighted)
        $0.addTarget(self, action: #selector(modifyProfileBtnAction), for: .touchUpInside)
    }
    
    private let modifyProfileBtnUnderlineView = UIView().then {
        $0.backgroundColor = Gen.Colors.gray02.color
    }
    
    // like
    
    private let likeContainerView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private let likeContentsContainerView = UIView().then {
        $0.backgroundColor = Gen.Colors.gray06.color
        $0.layer.cornerRadius = 12
    }
    
    private let likeContentsImageView = UIImageView().then {
        $0.image = Gen.Images.likeList.image
    }
    
    private let likeContentsLabel = UILabel().then {
        $0.font = .fonts(.subTitle)
        $0.textColor = Gen.Colors.gray02.color
        $0.text = "좋아요 한 전시기록"
    }
    
    private lazy var likeContentsCntLabel = UILabel().then {
        $0.font = .fonts(.header3)
        $0.textColor = Gen.Colors.black.color
        $0.text = "\(LikeManager.shared.likeList.count)"
    }
    
    private lazy var showLikeListBtn = UIButton().then {
        $0.backgroundColor = .clear
        $0.addTarget(self, action: #selector(showLikeListAction), for: .touchUpInside)
    }
    
    // setting
    
    private let settingContainerView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private let settingTitleContainerView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private let settingTitleLabel = UILabel().then {
        $0.font = .fonts(.header3)
        $0.textColor = Gen.Colors.gray01.color
        $0.text = "나의 계정설정"
    }
    
    private let settingTitleUnderlineView = UIView().then {
        $0.backgroundColor = Gen.Colors.gray01.color
    }
    
    private let loginInfoContainerView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private let loginInfoTitleLabel = UILabel().then {
        $0.font = .fonts(.subTitle)
        $0.textColor = Gen.Colors.gray02.color
        $0.text = "로그인 정보"
    }
    
    private lazy var loginInfoBtn = UIButton().then {
        $0.backgroundColor = .clear
        $0.addTarget(self, action: #selector(loginInfoAction), for: .touchUpInside)
    }
    
    private let pushNotiContainerView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private let pushNotiTitleLabel = UILabel().then {
        $0.font = .fonts(.subTitle)
        $0.textColor = Gen.Colors.gray02.color
        $0.text = "푸시 알림 허용"
    }
    
    private let pushNotiToggleBtn = UISwitch().then {
        $0.onTintColor = Gen.Colors.black.color
    }
    
    private let pushNotiHelpLabel = UILabel().then {
        $0.font = .fonts(.caption)
        $0.textColor = Gen.Colors.gray03.color
        $0.text = "전시회를 다녀오고, 시간이 지나면 알려드립니다."
    }
    
    // about
    
    private let aboutContainerView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private let aboutTitleContainerView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private let aboutTitleLabel = UILabel().then {
        $0.font = .fonts(.header3)
        $0.textColor = Gen.Colors.gray01.color
        $0.text = "About Archive"
    }
    
    private let aboutTitleUnderlineView = UIView().then {
        $0.backgroundColor = Gen.Colors.gray01.color
    }
    
    private let aboutInfoContainerView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private let aboutInfoTitleLabel = UILabel().then {
        $0.font = .fonts(.subTitle)
        $0.textColor = Gen.Colors.gray02.color
        $0.text = "아카이브 소개"
    }
    
    private lazy var aboutInfoBtn = UIButton().then {
        $0.backgroundColor = .clear
        $0.addTarget(self, action: #selector(aboutInfoAction), for: .touchUpInside)
    }
    
    private let termsInfoContainerView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private let termsInfoTitleLabel = UILabel().then {
        $0.font = .fonts(.subTitle)
        $0.textColor = Gen.Colors.gray02.color
        $0.text = "이용약관 보기"
    }
    
    private lazy var termsInfoBtn = UIButton().then {
        $0.backgroundColor = .clear
        $0.addTarget(self, action: #selector(termsInfoAction), for: .touchUpInside)
    }
    
    private let privacyInfoContainerView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private let privacyInfoTitleLabel = UILabel().then {
        $0.font = .fonts(.subTitle)
        $0.textColor = Gen.Colors.gray02.color
        $0.text = "개인정보 처리방침"
    }
    
    private lazy var privacyInfoBtn = UIButton().then {
        $0.backgroundColor = .clear
        $0.addTarget(self, action: #selector(privacyInfoAction), for: .touchUpInside)
    }
    
    private let versionInfoContainerView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private let versionInfoTitleLabel = UILabel().then {
        $0.font = .fonts(.subTitle)
        $0.textColor = Gen.Colors.gray03.color
        $0.text = "현재 버전"
    }
    
    private lazy var versionInfoLabel = UILabel().then {
        $0.font = .fonts(.caption)
        $0.textColor = Gen.Colors.gray03.color
        $0.text = "v\((Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "0")"
    }
    
    // MARK: private property
    
    // MARK: property
    var disposeBag: DisposeBag = DisposeBag()
    
    // MARK: lifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.likeQueryDoneNotificationReceive(notification:)), name: Notification.Name(NotificationDefine.LIKE_QUERY_DONE), object: nil)
    }
    
    init(reactor: MyPageReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
        setUp()
    }
    
    override func loadView() {
        super.loadView()
        
        self.view.addSubview(self.mainBackgroundView)
        self.mainBackgroundView.snp.makeConstraints {
            $0.edges.equalTo(self.view)
        }
        
        self.view.addSubview(self.mainContentsView)
        let safeGuide = self.view.safeAreaLayoutGuide
        self.mainContentsView.snp.makeConstraints {
            $0.edges.equalTo(safeGuide)
        }
        
        self.mainContentsView.addSubview(self.scrollView)
        self.scrollView.addSubview(self.stackView)
        self.scrollView.snp.makeConstraints {
            $0.edges.equalTo(self.mainContentsView)
            $0.width.equalTo(self.mainContentsView)
        }
        
        self.stackView.snp.makeConstraints {
            $0.top.bottom.equalTo(self.scrollView)
            $0.leading.equalTo(self.scrollView).offset(32)
            $0.trailing.equalTo(self.scrollView).offset(-32)
        }
        
        self.myProfileContainerView.snp.makeConstraints {
            $0.width.equalTo(UIScreen.main.bounds.width - 64)
        }
        
        self.likeContainerView.snp.makeConstraints {
            $0.width.equalTo(UIScreen.main.bounds.width - 64)
        }
        
        self.settingContainerView.snp.makeConstraints {
            $0.width.equalTo(UIScreen.main.bounds.width - 64)
        }
        
        self.aboutContainerView.snp.makeConstraints {
            $0.width.equalTo(UIScreen.main.bounds.width - 64)
        }
        
        self.myProfileContainerView.addSubview(self.profileImageContainerView)
        self.profileImageContainerView.snp.makeConstraints {
            $0.leading.equalTo(self.myProfileContainerView)
            $0.top.equalTo(self.myProfileContainerView).offset(12)
            $0.bottom.equalTo(self.myProfileContainerView).offset(-12)
            $0.width.height.equalTo(62)
        }
        
        self.profileImageContainerView.addSubview(self.profileImageView)
        self.profileImageView.snp.makeConstraints {
            $0.edges.equalTo(self.profileImageContainerView)
        }
        
        self.myProfileContainerView.addSubview(self.nameLabel)
        self.nameLabel.snp.makeConstraints {
            $0.leading.equalTo(self.profileImageContainerView.snp.trailing).offset(16)
            $0.top.equalTo(self.profileImageContainerView)
        }
        
        self.myProfileContainerView.addSubview(self.modifyProfileBtnUnderlineView)
        self.modifyProfileBtnUnderlineView.snp.makeConstraints {
            $0.bottom.equalTo(self.profileImageContainerView)
            $0.height.equalTo(1)
            $0.width.equalTo(64)
            $0.leading.equalTo(self.profileImageContainerView.snp.trailing).offset(16)
        }
        
        self.myProfileContainerView.addSubview(self.modifyProfileBtn)
        self.modifyProfileBtn.snp.makeConstraints {
            $0.bottom.equalTo(self.modifyProfileBtnUnderlineView.snp.top).offset(4)
            $0.leading.equalTo(self.modifyProfileBtnUnderlineView)
            $0.width.equalTo(64)
            $0.height.equalTo(31)
        }
        
        // Like
        
        self.likeContainerView.addSubview(self.likeContentsContainerView)
        self.likeContentsContainerView.snp.makeConstraints {
            $0.leading.trailing.equalTo(self.likeContainerView)
            $0.top.bottom.equalTo(self.likeContainerView).offset(20)
            $0.height.equalTo(60)
        }
        
        self.likeContentsContainerView.addSubview(self.likeContentsImageView)
        self.likeContentsImageView.snp.makeConstraints {
            $0.leading.equalTo(self.likeContentsContainerView).offset(20)
            $0.centerY.equalTo(self.likeContentsContainerView)
            $0.width.height.equalTo(40)
        }
        
        self.likeContentsContainerView.addSubview(self.likeContentsCntLabel)
        self.likeContentsCntLabel.snp.makeConstraints {
            $0.trailing.equalTo(self.likeContentsContainerView.snp.trailing).offset(-20)
            $0.centerY.equalTo(self.likeContentsContainerView)
        }
        
        self.likeContentsContainerView.addSubview(self.likeContentsLabel)
        self.likeContentsLabel.snp.makeConstraints {
            $0.leading.equalTo(self.likeContentsImageView.snp.trailing).offset(4)
            $0.centerY.equalTo(self.likeContentsContainerView)
            $0.trailing.lessThanOrEqualTo(self.likeContentsCntLabel.snp.leading).offset(4)
        }
        
        self.likeContainerView.addSubview(self.showLikeListBtn)
        self.showLikeListBtn.snp.makeConstraints {
            $0.edges.equalTo(self.likeContainerView)
        }
        
        // setting
        
        self.settingContainerView.addSubview(self.settingTitleContainerView)
        self.settingTitleContainerView.snp.makeConstraints {
            $0.top.equalTo(self.settingContainerView).offset(20)
            $0.leading.trailing.equalTo(self.settingContainerView)
            $0.height.equalTo(62)
        }
        
        self.settingTitleContainerView.addSubview(self.settingTitleLabel)
        self.settingTitleLabel.snp.makeConstraints {
            $0.centerY.equalTo(self.settingTitleContainerView)
            $0.leading.trailing.equalTo(self.settingTitleContainerView)
        }
        
        self.settingTitleContainerView.addSubview(self.settingTitleUnderlineView)
        self.settingTitleUnderlineView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalTo(self.settingTitleContainerView)
            $0.height.equalTo(1)
        }
        
        self.settingContainerView.addSubview(self.loginInfoContainerView)
        self.loginInfoContainerView.snp.makeConstraints {
            $0.top.equalTo(self.settingTitleContainerView.snp.bottom).offset(12)
            $0.height.equalTo(48)
        }
        
        self.loginInfoContainerView.addSubview(self.loginInfoTitleLabel)
        self.loginInfoTitleLabel.snp.makeConstraints {
            $0.leading.trailing.equalTo(self.loginInfoContainerView)
            $0.centerY.equalTo(self.loginInfoContainerView)
        }
        
        self.loginInfoContainerView.addSubview(self.loginInfoBtn)
        self.loginInfoBtn.snp.makeConstraints {
            $0.edges.equalTo(self.loginInfoContainerView)
        }
        
        self.settingContainerView.addSubview(pushNotiContainerView)
        self.pushNotiContainerView.snp.makeConstraints {
            $0.top.equalTo(self.loginInfoContainerView.snp.bottom)
            $0.leading.trailing.equalTo(self.settingContainerView)
            $0.height.equalTo(87)
            $0.bottom.equalTo(self.settingContainerView)
        }
        
        self.pushNotiContainerView.addSubview(self.pushNotiTitleLabel)
        self.pushNotiTitleLabel.snp.makeConstraints {
            $0.leading.equalTo(self.pushNotiContainerView)
            $0.top.equalTo(self.pushNotiContainerView).offset(15)
        }
        
        self.pushNotiContainerView.addSubview(self.pushNotiToggleBtn)
        self.pushNotiToggleBtn.snp.makeConstraints {
            $0.centerY.equalTo(self.pushNotiTitleLabel)
            $0.trailing.equalTo(self.pushNotiContainerView).offset(-32)
        }
        
        self.pushNotiContainerView.addSubview(self.pushNotiHelpLabel)
        self.pushNotiHelpLabel.snp.makeConstraints {
            $0.leading.equalTo(self.pushNotiContainerView)
            $0.top.equalTo(self.pushNotiTitleLabel.snp.bottom).offset(13)
        }
        
        // MARK: about
        
        self.aboutContainerView.addSubview(self.aboutTitleContainerView)
        self.aboutTitleContainerView.snp.makeConstraints {
            $0.top.equalTo(self.aboutContainerView).offset(20)
            $0.leading.trailing.equalTo(self.aboutContainerView)
            $0.height.equalTo(62)
        }

        self.aboutTitleContainerView.addSubview(self.aboutTitleLabel)
        self.aboutTitleLabel.snp.makeConstraints {
            $0.centerY.equalTo(self.aboutTitleContainerView)
            $0.leading.trailing.equalTo(self.aboutTitleContainerView)
        }

        self.aboutTitleContainerView.addSubview(self.aboutTitleUnderlineView)
        self.aboutTitleUnderlineView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalTo(self.aboutTitleContainerView)
            $0.height.equalTo(1)
        }
        
        self.aboutContainerView.addSubview(self.aboutInfoContainerView)
        self.aboutInfoContainerView.snp.makeConstraints {
            $0.top.equalTo(self.aboutTitleContainerView.snp.bottom).offset(12)
            $0.height.equalTo(48)
        }

        self.aboutInfoContainerView.addSubview(self.aboutInfoTitleLabel)
        self.aboutInfoTitleLabel.snp.makeConstraints {
            $0.leading.trailing.equalTo(self.aboutInfoContainerView)
            $0.centerY.equalTo(self.aboutInfoContainerView)
        }

        self.aboutInfoContainerView.addSubview(self.aboutInfoBtn)
        self.aboutInfoBtn.snp.makeConstraints {
            $0.edges.equalTo(self.aboutInfoContainerView)
        }

        self.aboutContainerView.addSubview(self.termsInfoContainerView)
        self.termsInfoContainerView.snp.makeConstraints {
            $0.top.equalTo(self.aboutInfoContainerView.snp.bottom)
            $0.height.equalTo(48)
        }

        self.termsInfoContainerView.addSubview(self.termsInfoTitleLabel)
        self.termsInfoTitleLabel.snp.makeConstraints {
            $0.leading.trailing.equalTo(self.termsInfoContainerView)
            $0.centerY.equalTo(self.termsInfoContainerView)
        }

        self.termsInfoContainerView.addSubview(self.termsInfoBtn)
        self.termsInfoBtn.snp.makeConstraints {
            $0.edges.equalTo(self.termsInfoContainerView)
        }

        self.aboutContainerView.addSubview(self.privacyInfoContainerView)
        self.privacyInfoContainerView.snp.makeConstraints {
            $0.top.equalTo(self.termsInfoContainerView.snp.bottom)
            $0.height.equalTo(48)
        }

        self.privacyInfoContainerView.addSubview(self.privacyInfoTitleLabel)
        self.privacyInfoTitleLabel.snp.makeConstraints {
            $0.leading.trailing.equalTo(self.privacyInfoContainerView)
            $0.centerY.equalTo(self.privacyInfoContainerView)
        }

        self.privacyInfoContainerView.addSubview(self.privacyInfoBtn)
        self.privacyInfoBtn.snp.makeConstraints {
            $0.edges.equalTo(self.privacyInfoContainerView)
        }

        self.aboutContainerView.addSubview(self.versionInfoContainerView)
        self.versionInfoContainerView.snp.makeConstraints {
            $0.top.equalTo(self.privacyInfoContainerView.snp.bottom)
            $0.height.equalTo(74)
            $0.bottom.equalTo(aboutContainerView)
        }

        self.versionInfoContainerView.addSubview(self.versionInfoTitleLabel)
        self.versionInfoTitleLabel.snp.makeConstraints {
            $0.leading.trailing.equalTo(self.versionInfoContainerView)
            $0.top.equalTo(self.versionInfoContainerView).offset(14)
        }

        self.versionInfoContainerView.addSubview(self.versionInfoLabel)
        self.versionInfoLabel.snp.makeConstraints {
            $0.leading.trailing.equalTo(self.versionInfoContainerView)
            $0.top.equalTo(self.versionInfoTitleLabel.snp.bottom).offset(4)
        }
        
        self.stackView.addArrangedSubview(self.myProfileContainerView)
        self.stackView.addArrangedSubview(self.likeContainerView)
        self.stackView.addArrangedSubview(self.settingContainerView)
        self.stackView.addArrangedSubview(self.aboutContainerView)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(reactor: MyPageReactor) {
        reactor.profileData
            .asDriver(onErrorJustReturn: ProfileData(imageUrl: "", nickNmae: ""))
            .drive(onNext: { [weak self] profile in
                if let userImageUrl = URL(string: profile.imageUrl) {
                    self?.profileImageView.kf.setImage(with: userImageUrl, placeholder: Gen.Images.userImagePlaceHolder.image)
                }
                self?.nameLabel.text = profile.nickNmae
            })
            .disposed(by: self.disposeBag)
    }
    
    deinit {
        print("\(self) deinit")
    }
    
    // MARK: private func
    
    private func setUp() {
        
    }
    
    @objc private func modifyProfileBtnAction() {
        self.reactor?.action.onNext(.moveToEditProfile)
    }
    
    @objc private func showLikeListAction() {
        self.reactor?.action.onNext(.moveToLikeList)
    }
    
    @objc private func loginInfoAction() {
        self.reactor?.action.onNext(.moveToLoginInfo)
    }
    
    @objc private func aboutInfoAction() {
        self.reactor?.action.onNext(.openAboutInfo)
    }
    
    @objc private func termsInfoAction() {
        self.reactor?.action.onNext(.openTerms)
    }
    
    @objc private func privacyInfoAction() {
        self.reactor?.action.onNext(.openPrivacy)
    }
    
    @objc private func likeQueryDoneNotificationReceive(notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.likeContentsCntLabel.text = "\(LikeManager.shared.likeList.count)"
        }
    }
    
    // MARK: func
    
    

}

extension MyPageViewController: MajorTabViewController {
    
    func willTabSeleted() {

    }

    func didTabSeleted() {

    }
    
    func willUnselected() {
        
    }
}

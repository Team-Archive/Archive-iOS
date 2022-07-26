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
    
    private let likeContentsCntLabel = UILabel().then {
        $0.font = .fonts(.header3)
        $0.textColor = Gen.Colors.black.color
        $0.text = "0"
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
    
    // MARK: private property
    
    // MARK: property
    var disposeBag: DisposeBag = DisposeBag()
    
    // MARK: lifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
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

        
        
        
        
        
        self.stackView.addArrangedSubview(self.myProfileContainerView)
        self.stackView.addArrangedSubview(self.likeContainerView)
        self.stackView.addArrangedSubview(self.settingContainerView)
        self.stackView.addArrangedSubview(self.aboutContainerView)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(reactor: MyPageReactor) {
        
    }
    
    deinit {
        print("\(self) deinit")
    }
    
    // MARK: private func
    
    private func setUp() {
        
    }
    
    @objc private func modifyProfileBtnAction() {
        print("modify")
    }
    
    @objc private func showLikeListAction() {
        print("showLikeListAction")
    }
    
    @objc private func loginInfoAction() {
        print("loginInfoAction")
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

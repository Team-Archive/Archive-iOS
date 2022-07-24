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
        $0.addTarget(self, action: #selector(modifyProfileBtnAction), for: .touchUpInside) 버튼이안눌려
    }
    
    private let modifyProfileBtnUnderlineView = UIView().then {
        $0.backgroundColor = Gen.Colors.gray02.color
    }
    
    // like
    
    private let likeContainerView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    // setting
    
    private let settingContainerView = UIView().then {
        $0.backgroundColor = .clear
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
        
//        let testView = UIView().then {
//            $0.backgroundColor = .brown
//        }
//        testView.snp.makeConstraints {
//            $0.height.equalTo(3300)
//            $0.width.equalTo(UIScreen.main.bounds.width)
//        }
//        let testView2 = UIView().then {
//            $0.backgroundColor = .blue
//        }
//        testView2.snp.makeConstraints {
//            $0.height.equalTo(3300)
//            $0.width.equalTo(UIScreen.main.bounds.width)
//        }
//        self.stackView.addArrangedSubview(testView)
//        self.stackView.addArrangedSubview(testView2)
        
        self.profileImageContainerView.snp.makeConstraints {
            $0.width.equalTo(UIScreen.main.bounds.width)
            $0.height.equalTo(500)
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
        
        self.stackView.addArrangedSubview(self.myProfileContainerView)
        
        
       
//        private lazy var modifyProfileBtn = UIButton().then {
//            $0.setTitleAllState("프로필 수정")
//            $0.setTitleColor(Gen.Colors.gray02.color, for: .normal)
//            $0.setTitleColor(Gen.Colors.gray03.color, for: .highlighted)
//            $0.addTarget(self, action: #selector(modifyProfileBtnAction), for: .touchUpInside)
//        }
//
//        private let  = UIView().then {
//            $0.backgroundColor = Gen.Colors.gray02.color
//        }
        
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

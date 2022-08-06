//
//  EditProfileViewController.swift
//  Archive
//
//  Created by hanwe on 2022/08/06.
//

import UIKit
import SnapKit
import ReactorKit
import RxCocoa
import Then

class EditProfileViewController: UIViewController, View, ActivityIndicatorable {
    
    // MARK: UI property
    
    private let mainBackgroundView = UIView().then {
        $0.backgroundColor = Gen.Colors.white.color
    }
    
    private let mainContentsView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private let profileImageContainerView = UIView().then {
        $0.backgroundColor = .clear
        $0.layer.cornerRadius = 31
    }
    
    private let profileImageView = UIImageView().then {
        $0.backgroundColor = .clear
        $0.image = Gen.Images.userImagePlaceHolder.image
    }
    
    private let prifileImageEditImageView = UIImageView().then {
        $0.image = Gen.Images.editProfile.image
    }
    
    private let nicknameTextField = ArchiveCheckTextField(originValue: LogInManager.shared.nickname,
                                                          placeHolder: "새로운 닉네임을 설정해보세요!",
                                                          checkBtnTitle: "중복 확인").then {
        $0.backgroundColor = .white
    }
    
    private let duplicatedNicknameWarningLabel = UILabel().then {
        $0.font = .fonts(.body)
        $0.textColor = Gen.Colors.gray02.color
        $0.text = "중복되지 않은 닉네임입니다"
    }
    
    private let confirmBtn = ArchiveConfirmButton().then {
        $0.setTitleAllState("프로필 변경")
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
        
        self.mainContentsView.addSubview(self.profileImageContainerView)
        self.profileImageContainerView.snp.makeConstraints {
            $0.top.equalTo(self.mainContentsView).offset(20)
            $0.width.height.equalTo(62)
            $0.centerX.equalTo(self.mainContentsView)
        }
        
        self.profileImageContainerView.addSubview(self.profileImageView)
        self.profileImageView.snp.makeConstraints {
            $0.edges.equalTo(self.profileImageContainerView)
        }
        
        self.mainContentsView.addSubview(self.prifileImageEditImageView)
        self.prifileImageEditImageView.snp.makeConstraints {
            $0.width.height.equalTo(20)
            $0.trailing.bottom.equalTo(self.profileImageContainerView)
        }
        
        self.mainContentsView.addSubview(self.nicknameTextField)
        self.nicknameTextField.snp.makeConstraints {
            $0.top.equalTo(self.profileImageContainerView.snp.bottom).offset(20)
            $0.leading.equalTo(self.mainContentsView).offset(32)
            $0.trailing.equalTo(self.mainContentsView).offset(-32)
            $0.height.equalTo(52)
        }
        
        self.mainContentsView.addSubview(self.duplicatedNicknameWarningLabel)
        self.duplicatedNicknameWarningLabel.snp.makeConstraints {
            $0.top.equalTo(self.nicknameTextField.snp.bottom).offset(10)
            $0.leading.equalTo(self.mainContentsView).offset(32)
            $0.trailing.equalTo(self.mainContentsView).offset(-32)
        }
        
        self.mainContentsView.addSubview(self.confirmBtn)
        self.confirmBtn.snp.makeConstraints {
            $0.top.equalTo(self.duplicatedNicknameWarningLabel.snp.bottom).offset(31)
            $0.height.equalTo(52)
            $0.leading.equalTo(self.mainContentsView).offset(32)
            $0.trailing.equalTo(self.mainContentsView).offset(-32)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(reactor: MyPageReactor) {
        
        reactor.err
            .asDriver(onErrorJustReturn: .init(.commonError))
            .drive(onNext: { err in
                CommonAlertView.shared.show(message: err.getMessage(), btnText: "확인", hapticType: .error, confirmHandler: {
                    CommonAlertView.shared.hide(nil)
                })
            })
            .disposed(by: self.disposeBag)
        
        reactor.state
            .map { $0.isLoading }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] in
                if $0 {
                    self?.startIndicatorAnimating()
                } else {
                    self?.stopIndicatorAnimating()
                }
            })
            .disposed(by: self.disposeBag)
        
    }
    
    deinit {
        print("\(self) deinit")
    }
    
    // MARK: private func
    
    // MARK: func

}

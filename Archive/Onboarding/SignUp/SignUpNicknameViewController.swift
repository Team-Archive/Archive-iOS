//
//  SignUpNicknameViewController.swift
//  Archive
//
//  Created by hanwe on 2022/10/08.
//

import UIKit
import SnapKit
import ReactorKit
import RxCocoa
import RxSwift
import Then

class SignUpNicknameViewController: UIViewController, View, ActivityIndicatorable {
    
    private enum Constant {
        static let progress: Float = 1.0
    }
    
    // MARK: UI property
    
    private let mainBackgroundView = UIView().then {
        $0.backgroundColor = Gen.Colors.white.color
    }
    
    private let mainContentsView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private let progressView = UIProgressView().then {
        $0.setProgress(0.75, animated: false)
        $0.progressTintColor = Gen.Colors.black.color
        $0.trackTintColor = Gen.Colors.gray05.color
        $0.progressViewStyle = .bar
    }
    
    private let mainTitleLabel = UILabel().then {
        $0.textColor = Gen.Colors.gray01.color
        $0.font = .fonts(.header2)
        $0.text = "Archive에서 사용할\n닉네임을 입력해주세요."
        $0.numberOfLines = 2
    }
    
    private let nicknameTextField = ArchiveCheckTextField(originValue: LogInManager.shared.profile.nickNmae,
                                                          placeHolder: "닉네임을 입력해주세요.",
                                                          checkBtnTitle: "중복 확인").then {
        $0.backgroundColor = .white
    }
    
    private let nicknameDupLabel = UILabel().then {
        $0.font = .fonts(.body)
        $0.textColor = Gen.Colors.gray02.color
        $0.text = "중복되지 않은 닉네임입니다"
    }
    
    private lazy var confirmBtn = ArchiveConfirmButton().then {
        $0.setTitleAllState("다음")
        $0.isEnabled = false
        $0.addTarget(self, action: #selector(confirm), for: .touchUpInside)
    }
    
    // MARK: private property
    
    // MARK: property
    
    var disposeBag: DisposeBag = DisposeBag()
    
    // MARK: lifeCycle
    
    init(reactor: SignUpReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "신고"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.progressView.setProgress(Constant.progress, animated: true)
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
        
        self.mainContentsView.addSubview(self.progressView)
        self.progressView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(self.mainContentsView)
            $0.height.equalTo(2)
        }
        
        self.mainContentsView.addSubview(self.mainTitleLabel)
        self.mainTitleLabel.snp.makeConstraints {
            $0.top.equalTo(self.mainContentsView).offset(40)
            $0.leading.equalTo(self.mainContentsView).offset(32)
            $0.trailing.equalTo(self.mainContentsView).offset(-32)
        }
        
        self.mainContentsView.addSubview(self.nicknameTextField)
        self.nicknameTextField.snp.makeConstraints {
            $0.leading.equalTo(self.mainContentsView).offset(32)
            $0.trailing.equalTo(self.mainContentsView).offset(-32)
            $0.height.equalTo(52)
            $0.top.equalTo(self.mainTitleLabel.snp.bottom).offset(26)
        }
        
        self.mainContentsView.addSubview(self.nicknameDupLabel)
        self.nicknameDupLabel.snp.makeConstraints {
            $0.leading.equalTo(self.mainContentsView).offset(32)
            $0.trailing.equalTo(self.mainContentsView).offset(-32)
            $0.top.equalTo(self.nicknameTextField.snp.bottom).offset(10)
        }
        
        self.mainContentsView.addSubview(self.confirmBtn)
        self.confirmBtn.snp.makeConstraints {
            $0.leading.equalTo(self.mainContentsView).offset(32)
            $0.trailing.equalTo(self.mainContentsView).offset(-32)
            $0.top.equalTo(self.nicknameDupLabel.snp.bottom).offset(26)
            $0.height.equalTo(52)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(reactor: SignUpReactor) {
        
        reactor.error
            .asDriver(onErrorJustReturn: .init("오류"))
            .drive(onNext: { errMsg in
                CommonAlertView.shared.show(message: errMsg, btnText: "확인", hapticType: .error, confirmHandler: {
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
        
        reactor.state
            .map { $0.isDuplicatedNickname }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] in
                if $0 {
                    self?.nicknameDupLabel.isHidden = false
                } else {
                    self?.nicknameDupLabel.isHidden = true
                }
            })
            .disposed(by: self.disposeBag)
        
        reactor.state
            .map { $0.isSuccessCheckedDuplicatedNickname }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] in
                if $0 {
                    self?.confirmBtn.isEnabled = true
                } else {
                    self?.confirmBtn.isEnabled = false
                    self?.nicknameDupLabel.isHidden = true
                }
            })
            .disposed(by: self.disposeBag)
        
        self.nicknameTextField.rx.text
            .subscribe(onNext: { [weak self] text in
                if reactor.currentState.isSuccessCheckedDuplicatedNickname {
                    reactor.action.onNext(.nicknameTextFieldIsChanged)
                }
            })
            .disposed(by: self.disposeBag)
        
        self.nicknameTextField.rx.check
            .subscribe(onNext: { [weak self] text in
                reactor.action.onNext(.checkIsDuplicatedNickname(text))
            })
            .disposed(by: self.disposeBag)
        
        
    }
    
    deinit {
        print("\(self) deinit")
    }
    
    // MARK: private func
    
    @objc private func confirm() {
        self.reactor?.action.onNext(.completeSignUp)
    }
    
    // MARK: func

}

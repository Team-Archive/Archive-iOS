//
//  EmailSignInViewController.swift
//  Archive
//
//  Created by hanwe on 2022/03/19.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa

final class EmailSignInViewController: UIViewController, StoryboardView, ActivityIndicatorable {
    
    // MARK: IBOutlet
    @IBOutlet weak var mainBackgroundView: UIView!
    @IBOutlet weak var mainContentsView: UIView!
    
    @IBOutlet weak var passwordInputView: InputView!
    @IBOutlet weak var passwordInputHelpLabel: UILabel!
    @IBOutlet weak var findPasswordBtn: UIButton!
    
    @IBOutlet weak var confirmBtn: DefaultButton!
    
    // MARK: private property
    
    // MARK: internal property
    
    var disposeBag = DisposeBag()
    
    // MARK: lifeCycle
    
    init?(coder: NSCoder, reactor: SignInReactor) {
        super.init(coder: coder)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func bind(reactor: SignInReactor) {
        
        reactor.error
            .asDriver(onErrorJustReturn: .init(.commonError))
            .drive(onNext: { err in
                if err.archiveErrorCode == .wrongPassword {
                    CommonAlertView.shared.show(message: "아이디 또는 비밀번호가 일치하지 않습니다.", btnText: "확인", hapticType: .error, confirmHandler: {
                        CommonAlertView.shared.hide()
                    })
                } else {
                    CommonAlertView.shared.show(message: "오류", subMessage: err.getMessage(), btnText: "확인", hapticType: .error, confirmHandler: {
                        CommonAlertView.shared.hide()
                    })
                }
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
        
        passwordInputView.rx.text.orEmpty
            .distinctUntilChanged()
            .map { Reactor.Action.passwordInput(text: $0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        confirmBtn.rx.tap
            .map { Reactor.Action.signIn }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.isEnableSignIn }
            .distinctUntilChanged()
            .bind(to: confirmBtn.rx.isEnabled)
            .disposed(by: disposeBag)
        
        findPasswordBtn.rx.tap
            .map { Reactor.Action.moveToFindPassword }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        reactor.toastMessage
            .asDriver(onErrorJustReturn: "")
            .drive(onNext: { [weak self] toastMessage in
                ArchiveToastView.shared.show(message: toastMessage, completeHandler: nil)
            })
            .disposed(by: self.disposeBag)
        
    }
    
    deinit {
        print("\(self) deinit")
    }
    
    // MARK: private function
    
    private func initUI() {
        self.title = "로그인"
        self.mainBackgroundView.backgroundColor = Gen.Colors.white.color
        self.mainContentsView.backgroundColor = .clear
        self.passwordInputView.placeholder = "비밀번호"
        self.passwordInputView.isSecureTextEntry = true
        
        self.passwordInputHelpLabel.font = .fonts(.body)
        self.passwordInputHelpLabel.textColor = Gen.Colors.gray02.color
        self.passwordInputHelpLabel.text = "영문/숫자포함 8~20자"
        
        self.findPasswordBtn.titleLabel?.font = .fonts(.button)
        self.findPasswordBtn.setTitleColor(Gen.Colors.gray02.color, for: .normal)
        self.findPasswordBtn.setTitleColor(Gen.Colors.gray05.color, for: .highlighted)
        self.findPasswordBtn.setTitle("비밀번호를 잊으셨나요", for: .normal)
        
        self.confirmBtn.setTitle("확인", for: .normal)
        self.confirmBtn.setTitleColor(Gen.Colors.white.color, for: .normal)
        self.confirmBtn.setTitle("확인", for: .highlighted)
        self.confirmBtn.setTitleColor(Gen.Colors.white.color, for: .highlighted)
    }
    
    // MARK: internal function
    
    // MARK: action
    
}

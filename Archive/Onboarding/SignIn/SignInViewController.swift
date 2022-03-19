//
//  SignInViewController.swift
//  Archive
//
//  Created by TTOzzi on 2021/10/02.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa

final class SignInViewController: UIViewController, StoryboardView, ActivityIndicatorable, SplashViewProtocol {
    
    // MARK: IBOutlet
    
    @IBOutlet var mainContainerView: UIView!
    @IBOutlet private weak var idInputView: InputView!
    @IBOutlet private weak var signInButton: DefaultButton!
    @IBOutlet private weak var signUpButton: UIButton!
    
    @IBOutlet weak var oAuthHelpLabel: UILabel!
    @IBOutlet weak var appleSignInBtn: UIButton!
    @IBOutlet weak var kakaoSignInBtn: UIButton!
    
    
    // MARK: private property
    
    // MARK: internal property
    
    var disposeBag = DisposeBag()
    weak var targetView: UIView?
    var attachedView: UIView? = SplashView.instance()
    
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
        setupAttributes()
        runSplashView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func bind(reactor: SignInReactor) {
        idInputView.rx.text.orEmpty
            .distinctUntilChanged()
            .map { Reactor.Action.idInput(text: $0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        signInButton.rx.tap
            .map { Reactor.Action.moveToEmailSignIn }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        signUpButton.rx.tap
            .map { Reactor.Action.signUp }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.isValidEmail }
            .distinctUntilChanged()
            .bind(to: signInButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        reactor.error
            .asDriver(onErrorJustReturn: "")
            .drive(onNext: { errorMsg in
                CommonAlertView.shared.show(message: errorMsg, btnText: "확인", hapticType: .error, confirmHandler: {
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
    
    // MARK: private function
    
    private func setupAttributes() {
        let tapOutside = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tapOutside)
        
        self.idInputView.placeholder = "아이디(이메일)"
        self.oAuthHelpLabel.font = .fonts(.body)
        self.oAuthHelpLabel.textColor = Gen.Colors.gray03.color
        self.oAuthHelpLabel.text = "다른 방법으로 로그인하기"
    }
    
    private func runSplashView() {
        if !AppConfigManager.shared.isPlayedIntroSplashView {
            AppConfigManager.shared.isPlayedIntroSplashView = true
            self.targetView = self.mainContainerView
            showSplashView(completion: {
                (self.attachedView as? SplashView)?.play()
            })
            (self.attachedView as? SplashView)?.isFinishAnimationFlag
                .asDriver(onErrorJustReturn: true)
                .drive(onNext: { [weak self] in
                    if $0 {
                        self?.hideSplashView(completion: { [weak self] in
                            self?.attachedView = nil
                        })
                    }
                })
                .disposed(by: self.disposeBag)
        }
    }
    
    // MARK: internal function
    
    // MARK: action
    
}

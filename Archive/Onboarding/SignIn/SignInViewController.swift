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

final class SignInViewController: UIViewController, StoryboardView, ActivityIndicatorable, FakeSplashViewProtocol {
    
    // MARK: IBOutlet
    
    @IBOutlet var mainContainerView: UIView!
    @IBOutlet private weak var idInputView: InputView!
    @IBOutlet private weak var signInButton: DefaultButton!
    @IBOutlet private weak var signUpButton: UIButton!
    
    @IBOutlet weak var oAuthHelpLabel: UILabel!
    @IBOutlet weak var appleSignInBtn: UIButton!
    @IBOutlet weak var kakaoSignInBtn: UIButton!
    
    @IBOutlet weak var debugBtn: UIButton!
    
    // MARK: private property
    
    private var debugTouchCnt: Int = 0
    
    // MARK: internal property
    
    var disposeBag = DisposeBag()
    weak var targetView: UIView?
    var attachedView: UIView? = FakeSplashView()
    
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
        self.targetView = self.view
        let status = ArchiveStatus.shared
        if !status.isShownFakeSplash {
            showSplashView()
            hideSplashView()
            status.runFakeSplash()
        }
        self.reactor?.action.onNext(.setIsKakaotalkInstalled)
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
            .asDriver(onErrorJustReturn: .init(.commonError))
            .drive(onNext: { err in
                CommonAlertView.shared.show(message: "오류", subMessage: err.getMessage(), btnText: "확인", hapticType: .error, confirmHandler: {
                    CommonAlertView.shared.hide()
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
        
        appleSignInBtn.rx.tap
            .map { Reactor.Action.signInWithApple }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        kakaoSignInBtn.rx.tap
            .map { Reactor.Action.signInWithKakao }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        debugBtn.rx.tap
            .map { Reactor.Action.debugTouchAction }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.showDebugPasswordInputView
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] in
                let alert = UIAlertController(title: "디버그용 치트키", message: "비밀번호를 입력해주세요", preferredStyle: .alert)
                alert.addTextField { [weak self] textField in
                    textField.isSecureTextEntry = true
                    textField.placeholder = "비밀번호"
                }
                alert.addTextField { [weak self] textField in
                    textField.placeholder = "테스트 서버 주소(공란시 개발서버)"
                }
                alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { [weak alert] (_) in
                    guard let text: String = alert?.textFields?[0].text else { return }
                    let url: String? = {
                        if alert?.textFields?[1].text == "" || alert?.textFields?[1].text == nil {
                            return nil
                        } else {
                            return alert?.textFields?[1].text
                        }
                    }()
                    let result = ArchiveStatus.shared.changeMode(mode: .debug(url: url), password: text)
                    switch result {
                    case .success(let mode):
                        CommonAlertView.shared.show(message: "모드 변경: \(mode)", btnText: "확인", hapticType: .success, confirmHandler: {
                            CommonAlertView.shared.hide()
                        })
                    case .failure(_):
                        CommonAlertView.shared.show(message: "비밀번호 불일치", btnText: "확인", hapticType: .error, confirmHandler: {
                            CommonAlertView.shared.hide()
                        })
                    }
                }))
                self?.present(alert, animated: true, completion: nil)
            })
            .disposed(by: self.disposeBag)
        
        reactor.toastMessage
            .asDriver(onErrorJustReturn: "")
            .drive(onNext: { [weak self] toastMessage in
                ArchiveToastView.shared.show(message: toastMessage, completeHandler: nil)
            })
            .disposed(by: self.disposeBag)
        
        reactor.state
            .map { $0.isKakaotalkInstalled }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] isInstalled in
                if !isInstalled {
                    guard let strongSelf = self else { return }
                    strongSelf.kakaoSignInBtn.isHidden = !isInstalled
                    strongSelf.kakaoSignInBtn.snp.updateConstraints {
                        $0.width.equalTo(0)
                        $0.leading.equalTo(strongSelf.appleSignInBtn.snp.trailing)
                    }
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
    
    // MARK: internal function
    
    // MARK: action
    
}

//
//  ChangePasswordViewController.swift
//  Archive
//
//  Created by hanwe on 2022/04/18.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa
import RxFlow

class ChangePasswordViewController: UIViewController, StoryboardView, ActivityIndicatorable {
    
    // MARK: IBOutlet
    @IBOutlet weak var mainBackgroundView: UIView!
    @IBOutlet weak var mainContentsView: UIView!
    @IBOutlet weak var mainTitleLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewContainerViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tempPasswordTitleLabel: UILabel!
    @IBOutlet private weak var tempPasswordInputView: InputView!
    
    @IBOutlet weak var passwordTitleLabel: UILabel!
    @IBOutlet private weak var passwordInputView: InputView!
    @IBOutlet private weak var englishCombinationCheckView: ConditionCheckmarkView!
    @IBOutlet private weak var numberCombinationCheckView: ConditionCheckmarkView!
    @IBOutlet private weak var countCheckView: ConditionCheckmarkView!
    @IBOutlet private weak var passwordConfirmInputView: InputView!
    @IBOutlet private weak var passwordCofirmCheckView: ConditionCheckmarkView!
    @IBOutlet private weak var nextButton: UIButton!
    
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
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification(_:)), name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotification(_:)), name: UIWindow.keyboardWillHideNotification, object: nil)
    }
    
    func bind(reactor: SignInReactor) {
        tempPasswordInputView.rx.text.orEmpty
            .distinctUntilChanged()
            .map { Reactor.Action.tempPasswordInput(text: $0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        passwordInputView.rx.text.orEmpty
            .distinctUntilChanged()
            .map { Reactor.Action.changepasswordInput(text: $0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        passwordConfirmInputView.rx.text.orEmpty
            .distinctUntilChanged()
            .map { Reactor.Action.passwordCofirmInput(text: $0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        nextButton?.rx.tap
            .map { Reactor.Action.changePassword }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        reactor.state
            .map { $0.isContainsEnglish }
            .distinctUntilChanged()
            .bind(to: englishCombinationCheckView.rx.isValid)
            .disposed(by: disposeBag)

        reactor.state
            .map { $0.isContainsNumber }
            .distinctUntilChanged()
            .bind(to: numberCombinationCheckView.rx.isValid)
            .disposed(by: disposeBag)

        reactor.state
            .map { $0.isWithinRange }
            .distinctUntilChanged()
            .bind(to: countCheckView.rx.isValid)
            .disposed(by: disposeBag)

        reactor.state
            .map { $0.isSamePasswordInput }
            .distinctUntilChanged()
            .bind(to: passwordCofirmCheckView.rx.isValid)
            .disposed(by: disposeBag)

        reactor.state
            .map { $0.isValidPassword }
            .distinctUntilChanged()
            .bind(to: nextButton.rx.isEnabled)
            .disposed(by: disposeBag)

        reactor.error
            .asDriver(onErrorJustReturn: "")
            .drive(onNext: { errMsg in
                CommonAlertView.shared.show(message: errMsg, subMessage: nil, btnText: "??????", hapticType: .error, confirmHandler: {
                    CommonAlertView.shared.hide(nil)
                })
            })
            .disposed(by: self.disposeBag)

        reactor.state
            .map { $0.isLoading }
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] in
                if $0 {
                    self?.startIndicatorAnimating()
                } else {
                    self?.stopIndicatorAnimating()
                }
            })
            .disposed(by: self.disposeBag)
        
        reactor.popToRootView
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] in
                self?.navigationController?.popToRootViewController(animated: true)
            })
            .disposed(by: self.disposeBag)
        
        reactor.toastMessage
            .asDriver(onErrorJustReturn: "")
            .drive(onNext: { [weak self] toastMessage in
                ArchiveToastView.shared.show(message: toastMessage, completeHandler: nil)
            })
            .disposed(by: self.disposeBag)

    }

    
    // MARK: private function
    
    private func initUI() {
        self.mainBackgroundView.backgroundColor = Gen.Colors.white.color
        self.mainContentsView.backgroundColor = .clear
        
        self.mainTitleLabel.font = .fonts(.header2)
        self.mainTitleLabel.textColor = Gen.Colors.gray01.color
        self.mainTitleLabel.text = "????????? ????????? ??????\n?????? ??????????????? ??????????????????."
        self.mainTitleLabel.numberOfLines = 2
        
        self.tempPasswordTitleLabel.font = .fonts(.body)
        self.tempPasswordTitleLabel.textColor = Gen.Colors.gray01.color
        self.tempPasswordTitleLabel.text = "??????????????????"
        
        self.passwordTitleLabel.font = .fonts(.body)
        self.passwordTitleLabel.textColor = Gen.Colors.gray01.color
        self.passwordTitleLabel.text = "?????? ????????????"
        
        self.tempPasswordInputView.isSecureTextEntry = true
        self.tempPasswordInputView.returnKeyType = .done
        self.passwordInputView.isSecureTextEntry = true
        self.passwordInputView.returnKeyType = .done
        self.passwordConfirmInputView.isSecureTextEntry = true
        self.passwordConfirmInputView.returnKeyType = .done
        
        self.englishCombinationCheckView.title = "????????????"
        self.numberCombinationCheckView.title = "????????????"
        self.countCheckView.title = "8-20??? ??????"
        self.passwordCofirmCheckView.title = "???????????? ??????"
    }
    
    @objc private func keyboardWillShowNotification(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.scrollViewContainerViewBottomConstraint.constant = keyboardSize.height
        }
    }
    
    @objc private func keyboardWillHideNotification(_ notification: Notification) {
        self.scrollViewContainerViewBottomConstraint.constant = 0
    }
    
    // MARK: internal function
    
    // MARK: action
    

}

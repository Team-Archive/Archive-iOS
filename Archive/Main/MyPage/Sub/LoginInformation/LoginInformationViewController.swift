//
//  LoginInformationViewController.swift
//  Archive
//
//  Created by hanwe on 2021/10/23.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa
import RxFlow

class LoginInformationViewController: UIViewController, StoryboardView, ActivityIndicatorable {

    // MARK: IBOutlet
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var scrollViewContainerView: UIView!
    @IBOutlet weak var scrollContainerViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mainContainerView: UIView!
    @IBOutlet weak var eMailTitleLabel: UILabel!
    @IBOutlet weak var eMailTextContainerView: UIView!
    @IBOutlet weak var eMailLabel: UILabel!
    @IBOutlet weak var eMailIconImageView: UIImageView!
    @IBOutlet weak var eMailIconWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var currentPasswordTitleLabel: UILabel!
    @IBOutlet weak var currentPasswordInputView: InputView!
    
    @IBOutlet weak var newPasswordTitleLabel: UILabel!
    @IBOutlet weak var newPasswordInputView: InputView!
    @IBOutlet weak var englishCombinationCheckView: ConditionCheckmarkView!
    @IBOutlet weak var numberCombinationCheckView: ConditionCheckmarkView!
    @IBOutlet weak var countCheckView: ConditionCheckmarkView!
    
    @IBOutlet weak var newPasswordConfirmInputView: InputView!
    @IBOutlet weak var newPasswordCofirmCheckView: ConditionCheckmarkView!
    @IBOutlet private weak var nextButton: UIButton!
    
    @IBOutlet weak var withdrawalBtn: UIButton!
    @IBOutlet weak var logoutBtn: UIButton!
    
    // MARK: private property
    
    private var originEMailIconWidthConstraint: CGFloat = 0
    private var originScrollContainerViewBottomConstraint: CGFloat = 0
    
    private lazy var activePlaceHolderAttributes = [
        NSAttributedString.Key.foregroundColor: Gen.Colors.gray03.color,
        NSAttributedString.Key.font: UIFont.fonts(.body)
    ]
    
    private lazy var nonActivePlaceHolderAttributes = [
        NSAttributedString.Key.foregroundColor: Gen.Colors.gray04.color,
        NSAttributedString.Key.font: UIFont.fonts(.body)
    ]
    
    // MARK: internal property
    var disposeBag: DisposeBag = DisposeBag()
    
    // MARK: lifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        self.reactor?.action.onNext(.refreshLoginType)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIWindow.keyboardWillHideNotification, object: nil)
        self.reactor?.action.onNext(.getEmail)
    }
    
    init?(coder: NSCoder, reactor: LoginInformationReactor) {
        super.init(coder: coder)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func bind(reactor: LoginInformationReactor) {
        reactor.state.map { $0.type }
        .asDriver(onErrorJustReturn: .kakao)
        .drive(onNext: { [weak self] type in
            switch type {
            case .eMail:
                self?.refreshUIForEMail()
            case .kakao:
                self?.refreshUIForKakao()
            case .apple:
                self?.refreshUIForApple()
            }
        })
        .disposed(by: self.disposeBag)
        
        self.withdrawalBtn.rx.tap
            .map { Reactor.Action.moveWithdrawalPage }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.logoutBtn.rx.tap
            .asDriver()
            .drive(onNext: {
                CommonAlertView.shared.show(message: "로그아웃 하시겠어요?", subMessage: "로그인을 한 상태에서만\n나의 전시들을 볼 수 있어요.", confirmBtnTxt: "로그아웃", cancelBtnTxt: "취소", confirmHandler: {
                    CommonAlertView.shared.hide(nil)
                    reactor.action.onNext(.logout)
                }, cancelHandler: {
                    CommonAlertView.shared.hide(nil)
                })
            })
            .disposed(by: self.disposeBag)
        
        reactor.state.map { $0.eMail }
        .bind(to: self.eMailLabel.rx.text)
        .disposed(by: self.disposeBag)
        
        currentPasswordInputView.rx.text.orEmpty
            .distinctUntilChanged()
            .map { Reactor.Action.currentPasswordInput(text: $0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        newPasswordInputView.rx.text.orEmpty
            .distinctUntilChanged()
            .map { Reactor.Action.changeNewPasswordInput(text: $0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        newPasswordConfirmInputView.rx.text.orEmpty
            .distinctUntilChanged()
            .map { Reactor.Action.newPasswordCofirmInput(text: $0) }
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
            .bind(to: newPasswordCofirmCheckView.rx.isValid)
            .disposed(by: disposeBag)

        reactor.state
            .map { $0.isValidPassword }
            .distinctUntilChanged()
            .bind(to: nextButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        reactor.error
            .asDriver(onErrorJustReturn: "")
            .drive(onNext: { errMsg in
                CommonAlertView.shared.show(message: errMsg, subMessage: nil, btnText: "확인", hapticType: .error, confirmHandler: {
                    CommonAlertView.shared.hide(nil)
                })
            })
            .disposed(by: self.disposeBag)
        
        reactor.toastMessage
            .asDriver(onErrorJustReturn: "")
            .drive(onNext: { [weak self] toastMessage in
                ArchiveToastView.shared.show(message: toastMessage, completeHandler: { [weak self] in
                    self?.navigationController?.popViewController(animated: true)
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
        
    }
    
    // MARK: private function
    
    private func initUI() {
        self.originScrollContainerViewBottomConstraint = self.scrollContainerViewBottomConstraint.constant
        self.backgroundView.backgroundColor = Gen.Colors.white.color
        self.scrollViewContainerView.backgroundColor = .clear
        self.scrollView.backgroundColor = .clear
        self.mainContainerView.backgroundColor = .clear
        self.eMailTitleLabel.font = .fonts(.body)
        self.eMailTitleLabel.textColor = Gen.Colors.gray01.color
        self.eMailTitleLabel.text = "이메일"
        self.eMailTextContainerView.layer.cornerRadius = 8
        self.eMailTextContainerView.layer.borderColor = Gen.Colors.gray04.color.cgColor
        self.eMailTextContainerView.layer.borderWidth = 1
        self.eMailLabel.font = .fonts(.body)
        self.eMailLabel.textColor = Gen.Colors.black.color
        self.originEMailIconWidthConstraint = self.eMailIconWidthConstraint.constant
        self.eMailLabel.font = .fonts(.body)
        
        self.currentPasswordTitleLabel.font = .fonts(.body)
        self.currentPasswordTitleLabel.textColor = Gen.Colors.gray01.color
        self.currentPasswordTitleLabel.text = "현재 비밀번호"
        self.currentPasswordInputView.isSecureTextEntry = true
        self.currentPasswordInputView.returnKeyType = .done
        self.currentPasswordInputView.placeholder = "현재 비밀번호를 입력해주세요."
        
        self.newPasswordTitleLabel.font = .fonts(.body)
        self.newPasswordTitleLabel.textColor = Gen.Colors.gray01.color
        self.newPasswordTitleLabel.text = "신규 비밀번호"
        
        self.newPasswordInputView.isSecureTextEntry = true
        self.newPasswordInputView.returnKeyType = .done
        self.newPasswordInputView.placeholder = "신규 비밀번호를 입력해주세요."
        self.newPasswordConfirmInputView.isSecureTextEntry = true
        self.newPasswordConfirmInputView.returnKeyType = .done
        self.newPasswordConfirmInputView.placeholder = "신규 비밀번호를 입력해주세요."
        
        self.englishCombinationCheckView.title = "영문조합"
        self.numberCombinationCheckView.title = "숫자조합"
        self.countCheckView.title = "8-20자 이내"
        self.newPasswordCofirmCheckView.title = "비밀번호 일치"
        
        self.withdrawalBtn.setTitle("회원탈퇴", for: .normal)
        self.withdrawalBtn.setTitleColor(Gen.Colors.gray04.color, for: .normal)
        self.withdrawalBtn.setTitle("회원탈퇴", for: .highlighted)
        self.withdrawalBtn.setTitleColor(Gen.Colors.gray04.color, for: .highlighted)
        self.withdrawalBtn.titleLabel?.font = .fonts(.body)
        self.logoutBtn.setTitle("로그아웃", for: .normal)
        self.logoutBtn.setTitleColor(Gen.Colors.gray04.color, for: .normal)
        self.logoutBtn.setTitle("로그아웃", for: .highlighted)
        self.logoutBtn.setTitleColor(Gen.Colors.gray04.color, for: .highlighted)
        self.logoutBtn.titleLabel?.font = .fonts(.body)
    }
    
    private func refreshUIForEMail() {
        self.eMailIconWidthConstraint.constant = 0
        self.eMailIconImageView.isHidden = true
        self.eMailLabel.textColor = Gen.Colors.gray04.color
        self.eMailTextContainerView.backgroundColor = Gen.Colors.gray06.color
        self.currentPasswordInputView.isEnabled = true
        self.currentPasswordInputView.backgroundColor = Gen.Colors.white.color
        self.newPasswordInputView.isEnabled = true
        self.newPasswordInputView.backgroundColor = Gen.Colors.white.color
        self.newPasswordConfirmInputView.isEnabled = true
        self.newPasswordConfirmInputView.backgroundColor = Gen.Colors.white.color
    }
    
    private func refreshUIForKakao() {
        refreshUIForSocialLogin()
        self.eMailIconImageView.image = Gen.Images.kakaotalk.image
    }
    
    private func refreshUIForApple() {
        refreshUIForSocialLogin()
        self.eMailIconImageView.image = Gen.Images.btnApple.image
    }
    
    private func refreshUIForSocialLogin() {
        self.eMailLabel.textColor = Gen.Colors.black.color
        self.eMailTextContainerView.backgroundColor = Gen.Colors.white.color
        self.currentPasswordInputView.isEnabled = false
        self.currentPasswordInputView.backgroundColor = Gen.Colors.gray05.color
        self.newPasswordInputView.isEnabled = false
        self.newPasswordInputView.backgroundColor = Gen.Colors.gray05.color
        self.newPasswordConfirmInputView.isEnabled = false
        self.newPasswordConfirmInputView.backgroundColor = Gen.Colors.gray05.color
        self.nextButton.isEnabled = false
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardHeight = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height else { return }
        var added: CGFloat = 0
        if UIDevice.current.hasNotch {
            added = 34
        }
        self.scrollContainerViewBottomConstraint.constant = keyboardHeight - added
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        self.scrollContainerViewBottomConstraint.constant = self.originScrollContainerViewBottomConstraint
        UIView.animate(withDuration: 1.0, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        })
    }
    
    // MARK: internal function
    
    // MARK: action

}

//
//  FindPasswordViewController.swift
//  Archive
//
//  Created by hanwe on 2022/04/16.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa

final class FindPasswordViewController: UIViewController, StoryboardView, ActivityIndicatorable {
    
    // MARK: IBOutlet
    
    @IBOutlet weak var mainBackgroundView: UIView!
    @IBOutlet weak var mainContentsView: UIView!
    @IBOutlet weak var mainTitleLabel: UILabel!
    @IBOutlet weak var emailContainerView: UIView!
    @IBOutlet weak var emailLabel: UILabel!
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
    
    func bind(reactor: SignInReactor) {
        
        reactor.error
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
        
        reactor.state
            .map { $0.id }
            .distinctUntilChanged()
            .bind(to: self.emailLabel.rx.text)
            .disposed(by: self.disposeBag)
        
        confirmBtn.rx.tap
            .map { Reactor.Action.sendTempPassword }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        reactor.toastMessage
            .asDriver(onErrorJustReturn: "")
            .drive(onNext: { [weak self] toastMessage in
                ArchiveToastView.shared.show(message: toastMessage, completeHandler: nil)
            })
            .disposed(by: self.disposeBag)
        
        reactor.pop
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] in 
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: self.disposeBag)
        
    }
    
    deinit {
        print("\(self) deinit")
    }
    
    // MARK: private function
    
    private func initUI() {
        self.title = "비밀번호 찾기"
        
        self.mainBackgroundView.backgroundColor = Gen.Colors.white.color
        self.mainContentsView.backgroundColor = .clear
        
        self.mainTitleLabel.font = .fonts(.header2)
        self.mainTitleLabel.textColor = Gen.Colors.gray01.color
        self.mainTitleLabel.text = "가입하신 이메일로\n임시 비밀번호가 발송됩니다."
        self.mainTitleLabel.numberOfLines = 2
        
        self.emailContainerView.backgroundColor = Gen.Colors.white.color
        self.emailContainerView.layer.cornerRadius = 8
        self.emailContainerView.layer.borderColor = Gen.Colors.gray04.color.cgColor
        self.emailContainerView.layer.borderWidth = 1
        
        self.emailLabel.font = .fonts(.body)
        self.emailLabel.textColor = Gen.Colors.gray02.color
        
        self.confirmBtn.setBackgroundColor(Gen.Colors.black.color, for: .normal)
        self.confirmBtn.setBackgroundColor(Gen.Colors.gray02.color, for: .highlighted)
        self.confirmBtn.setTitle("확인", for: .normal)
        self.confirmBtn.setTitle("확인", for: .highlighted)
        self.confirmBtn.setTitle("확인", for: .focused)
    }
    
    // MARK: internal function
    
    // MARK: action
    
}

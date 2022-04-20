//
//  TermsAgreementForOAuthViewController.swift
//  Archive
//
//  Created by hanwe on 2022/04/13.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa

final class TermsAgreementForOAuthViewController: UIViewController, StoryboardView, ActivityIndicatorable {
    
    @IBOutlet private weak var checkAllButton: UIButton!
    @IBOutlet private weak var agreeTermsButton: UIButton!
    @IBOutlet private weak var viewTermsButton: UIButton!
    @IBOutlet private weak var agreePersonalInformationPolicyButton: UIButton!
    @IBOutlet private weak var viewPersonalInformationPolicyButton: UIButton!
    @IBOutlet private weak var nextButton: UIButton!
    var disposeBag = DisposeBag()
    
    init?(coder: NSCoder, reactor: SignUpReactor) {
        super.init(coder: coder)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func bind(reactor: SignUpReactor) {
        checkAllButton.rx.tap
            .map { Reactor.Action.checkAll }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        agreeTermsButton.rx.tap
            .map { Reactor.Action.agreeTerms }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        viewTermsButton.rx.tap
            .map { Reactor.Action.viewTerms }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        agreePersonalInformationPolicyButton.rx.tap
            .map { Reactor.Action.agreePersonalInformationPolicy }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        viewPersonalInformationPolicyButton.rx.tap
            .map { Reactor.Action.viewPersonalInformationPolicy }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        nextButton.rx.tap
            .map { Reactor.Action.registKakaoLogin }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.isCheckAll }
            .distinctUntilChanged()
            .bind(to: checkAllButton.rx.isSelected)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.isAgreeTerms }
            .distinctUntilChanged()
            .bind(to: agreeTermsButton.rx.isSelected)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.isAgreePersonalInformationPolicy }
            .distinctUntilChanged()
            .bind(to: agreePersonalInformationPolicyButton.rx.isSelected)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.isCheckAll }
            .distinctUntilChanged()
            .bind(to: nextButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
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
}

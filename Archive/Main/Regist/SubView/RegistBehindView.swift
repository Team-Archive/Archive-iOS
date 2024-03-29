//
//  RegistBehindView.swift
//  Archive
//
//  Created by hanwe on 2022/08/23.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

@objc protocol RegistBehindViewDelegate: AnyObject {
    @objc optional func requestFlip()
}

class RegistBehindView: UIView {
    
    // MARK: UIProperty
    
    private let mainBackgroundView = UIView().then {
        $0.backgroundColor = Gen.Colors.white.color
    }
    
    private let topGradationView = UIImageView().then {
        $0.backgroundColor = .clear
        $0.image = Gen.Images.navigationGradation.image
    }
    
    private let scrollContainerView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private let scrollView = UIScrollView().then {
        $0.backgroundColor = .clear
    }
    
    private let mainContentsView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private let topView = UIView().then {
        $0.backgroundColor = Emotion.pleasant.color
    }
    
    private lazy var topImageView = UIImageView().then {
        $0.image = Gen.Images.iconDropDown.image
        $0.isUserInteractionEnabled = true
        let taps = UITapGestureRecognizer(target: self, action: #selector(self.flip(_:)))
        $0.addGestureRecognizer(taps)
    }
    
    private let leftTriImgView = UIImageView().then {
        $0.image = Gen.Images.triLeft.image
    }
    
    private let rightTriImgView = UIImageView().then {
        $0.image = Gen.Images.triRight.image
    }
    
    private let archiveNameLabel = UILabel().then {
        $0.font = .fonts(.subTitle)
        $0.textColor = Gen.Colors.black.color
        $0.text = "무슨 전시를 감상했나요?*"
    }
    
    private let archiveNameTextField = ClearTextField().then {
        $0.placeholder = "전시명을 입력해주세요."
    }
    
    private let whenLabel = UILabel().then {
        $0.font = .fonts(.subTitle)
        $0.textColor = Gen.Colors.black.color
        $0.text = "언제 전시를 감상했나요?*"
    }
    
    private let whenTextField = ClearTextField(isDatePicker: true).then {
        $0.placeholder = "YY/MM/DD"
    }
    
    private let friendsLabel = UILabel().then {
        $0.font = .fonts(.subTitle)
        $0.textColor = Gen.Colors.black.color
        $0.text = "누구와 관람하셨나요?"
    }
    
    private let friendsTextField = ClearTextField().then {
        $0.placeholder = "동행인은 쉼표로 구분됩니다."
    }
    
    private let toggleView = ExplainToggleView().then {
        $0.titleText = "전시 기록 공개"
        $0.helpText = "전시 기록을 공개하면, 다른 사람들도 내 기록을 볼 수 있습니다."
        $0.toggleTintColor = Gen.Colors.gray03.color
        $0.toggleOnTintColor = Gen.Colors.black.color
    }
    
    // MARK: private property
    
    private let navigationHeight: CGFloat
    private let disposeBag = DisposeBag()
    private weak var reactor: RegistReactor?
    
    // MARK: internal property
    
    var emotion: Emotion? {
        didSet {
            guard let emotion = emotion else { return }
            DispatchQueue.main.async { [weak self] in
                self?.topView.backgroundColor = emotion.color
            }
        }
    }
    
    weak var delegate: RegistBehindViewDelegate?
    
    // MARK: lifeCycle
    
    init(navigationHeight: CGFloat, reactor: RegistReactor?) {
        self.navigationHeight = navigationHeight
        self.reactor = reactor
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        setup()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("\(self) deinit")
    }
    
    // MARK: private function
    
    private func setup() {
        self.addSubview(self.mainBackgroundView)
        self.mainBackgroundView.snp.makeConstraints {
            $0.edges.equalTo(self)
        }
        
        self.addSubview(self.scrollContainerView)
        self.scrollContainerView.snp.makeConstraints {
            $0.edges.equalTo(self)
        }
        
        self.scrollContainerView.addSubview(self.scrollView)
        self.scrollView.snp.makeConstraints {
            $0.edges.equalTo(self.scrollContainerView)
        }
        
        self.scrollView.addSubview(self.mainContentsView)
        self.mainContentsView.snp.makeConstraints {
            $0.edges.equalTo(self.scrollView).priority(750)
            $0.width.equalTo(self.scrollView).priority(1000)
        }
        
        self.mainContentsView.addSubview(self.topView)
        self.topView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(self.mainContentsView)
            $0.height.equalTo(135)
        }
        
        self.topView.addSubview(self.topImageView)
        self.topImageView.snp.makeConstraints {
            $0.centerX.equalTo(self.topView)
            $0.width.height.equalTo(44)
            $0.bottom.equalTo(self.topView)
        }
        
        self.topView.addSubview(self.leftTriImgView)
        self.leftTriImgView.snp.makeConstraints {
            $0.width.height.equalTo(44)
            $0.leading.equalTo(self.topView)
            $0.bottom.equalTo(self.topView).offset(22)
        }
        
        self.topView.addSubview(self.rightTriImgView)
        self.rightTriImgView.snp.makeConstraints {
            $0.width.height.equalTo(44)
            $0.trailing.equalTo(self.topView)
            $0.bottom.equalTo(self.topView).offset(22)
        }
        
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        let statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        self.mainContentsView.addSubview(self.topGradationView)
        self.topGradationView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(self.mainContentsView)
            $0.height.equalTo(statusBarHeight + (self.navigationHeight))
        }
        
        
        self.mainContentsView.addSubview(self.archiveNameLabel)
        self.archiveNameLabel.snp.makeConstraints {
            $0.top.equalTo(self.topView.snp.bottom).offset(32)
            $0.leading.equalTo(self.mainContentsView).offset(32)
            $0.trailing.equalTo(self.mainContentsView).offset(-32)
        }
        
        self.mainContentsView.addSubview(self.archiveNameTextField)
        self.archiveNameTextField.snp.makeConstraints {
            $0.leading.trailing.equalTo(self.archiveNameLabel)
            $0.top.equalTo(self.archiveNameLabel.snp.bottom).offset(10)
            $0.height.equalTo(48)
        }
        
        self.mainContentsView.addSubview(self.whenLabel)
        self.whenLabel.snp.makeConstraints {
            $0.leading.trailing.equalTo(self.archiveNameTextField)
            $0.top.equalTo(self.archiveNameTextField.snp.bottom).offset(28)
        }
        
        self.mainContentsView.addSubview(self.whenTextField)
        self.whenTextField.snp.makeConstraints {
            $0.leading.trailing.equalTo(self.archiveNameLabel)
            $0.top.equalTo(self.whenLabel.snp.bottom).offset(10)
            $0.height.equalTo(48)
        }
        
        self.mainContentsView.addSubview(self.friendsLabel)
        self.friendsLabel.snp.makeConstraints {
            $0.leading.trailing.equalTo(self.archiveNameTextField)
            $0.top.equalTo(self.whenTextField.snp.bottom).offset(28)
        }
        
        self.mainContentsView.addSubview(self.friendsTextField)
        self.friendsTextField.snp.makeConstraints {
            $0.leading.trailing.equalTo(self.archiveNameLabel)
            $0.top.equalTo(self.friendsLabel.snp.bottom).offset(10)
            $0.height.equalTo(48)
        }
        
        self.mainContentsView.addSubview(self.toggleView)
        self.toggleView.snp.makeConstraints {
            $0.leading.trailing.equalTo(self.archiveNameLabel)
            $0.top.equalTo(self.friendsTextField.snp.bottom).offset(28)
            $0.bottom.equalTo(self.mainContentsView).offset(-10)
        }
    }
    
    private func bind() {
        self.archiveNameTextField.rx.doneButtonClicked
            .subscribe(onNext: { [weak self] text in
                self?.reactor?.action.onNext(.setArchiveName(text))
            })
            .disposed(by: self.disposeBag)
        
        self.archiveNameTextField.rx.didEndEditing
            .subscribe(onNext: { [weak self] text in
                if text != "" {
                    self?.reactor?.action.onNext(.setArchiveName(text))
                }
            })
            .disposed(by: self.disposeBag)
        
        self.whenTextField.rx.didSelectedDate
            .subscribe(onNext: { [weak self] text in
                self?.reactor?.action.onNext(.setVisitDate(text))
            })
            .disposed(by: self.disposeBag)
        
        self.friendsTextField.rx.doneButtonClicked
            .subscribe(onNext: { [weak self] text in
                self?.reactor?.action.onNext(.setFriends(text))
            })
            .disposed(by: self.disposeBag)
        
        self.friendsTextField.rx.didEndEditing
            .subscribe(onNext: { [weak self] text in
                if text != "" {
                    self?.reactor?.action.onNext(.setFriends(text))
                }
            })
            .disposed(by: self.disposeBag)
        
        self.toggleView.rx.toggleState
            .subscribe(onNext: { [weak self] isOn in
                self?.reactor?.action.onNext(.setIsPublic(isOn))
            })
            .disposed(by: self.disposeBag)
    }
    
    @objc private func flip(_ recognizer: UITapGestureRecognizer) {
        self.delegate?.requestFlip?()
    }
    
    // MARK: internal function
    
    func selectArchiveNameTextField() {
        DispatchQueue.main.async { [weak self] in
            _ = self?.archiveNameTextField.becomeFirstResponder()
        }
    }

}

class RegistBehindViewDelegateProxy: DelegateProxy<RegistBehindView, RegistBehindViewDelegate>, DelegateProxyType, RegistBehindViewDelegate {
    
    
    static func currentDelegate(for object: RegistBehindView) -> RegistBehindViewDelegate? {
        return object.delegate
    }
    
    static func setCurrentDelegate(_ delegate: RegistBehindViewDelegate?, to object: RegistBehindView) {
        object.delegate = delegate
    }
    
    static func registerKnownImplementations() {
        self.register { (view) -> RegistBehindViewDelegateProxy in
            RegistBehindViewDelegateProxy(parentObject: view, delegateProxy: self)
        }
    }
}

extension Reactive where Base: RegistBehindView {
    var delegate: DelegateProxy<RegistBehindView, RegistBehindViewDelegate> {
        return RegistBehindViewDelegateProxy.proxy(for: self.base)
    }
    
    var requestFlip: Observable<Void> {
        return delegate.methodInvoked(#selector(RegistBehindViewDelegate.requestFlip))
            .map { _ in
                return ()
            }
    }
}

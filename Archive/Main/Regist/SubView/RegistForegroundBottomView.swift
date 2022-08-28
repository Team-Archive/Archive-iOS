//
//  RegistForegroundBottomView.swift
//  Archive
//
//  Created by hanwe on 2022/08/15.
//

import UIKit
import Then
import SnapKit
import RxCocoa
import RxSwift

@objc protocol RegistForegroundBottomViewDelegate: AnyObject {
    @objc optional func clickedRegistTitle()
}

class RegistForegroundBottomView: UIView {

    // MARK: private UI property
     
    private let helpTitleLabel = UILabel().then {
        $0.font = .fonts(.subTitle)
        $0.textColor = Gen.Colors.black.color
        $0.text = "무슨 전시를 감상했나요?*"
    }
    
    private lazy var titlePlaceHolderLabel = UILabel().then {
        $0.font = .fonts(.header2)
        $0.textColor = Gen.Colors.gray03.color
        $0.text = "전시명을 입력해주세요."
        $0.isUserInteractionEnabled = true
        let taps = UITapGestureRecognizer(target: self, action: #selector(self.regist(_:)))
        $0.addGestureRecognizer(taps)
    }
    
    private lazy var titleLabel = UILabel().then {
        $0.font = .fonts(.header2)
        $0.textColor = Gen.Colors.black.color
        $0.numberOfLines = 2
        $0.isUserInteractionEnabled = true
        let taps = UITapGestureRecognizer(target: self, action: #selector(self.regist(_:)))
        $0.addGestureRecognizer(taps)
    }
    
    private let underLineView = UIView().then {
        $0.backgroundColor = Gen.Colors.gray04.color
    }
    
    // MARK: internal UI property
    
    // MARK: property
    
    weak var delegate: RegistForegroundBottomViewDelegate?
    
    // MARK: private Property
    
    // MARK: lifeCycle
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        setup()
    }
    
    // MARK: private func
    
    private func setup() {
        self.backgroundColor = .clear
        
        self.addSubview(self.helpTitleLabel)
        self.helpTitleLabel.snp.makeConstraints {
            $0.leading.equalTo(self).offset(32)
            $0.trailing.equalTo(self).offset(-32)
            $0.top.equalTo(self).offset(33)
        }
        
        self.addSubview(self.titlePlaceHolderLabel)
        self.titlePlaceHolderLabel.snp.makeConstraints {
            $0.leading.trailing.equalTo(self.helpTitleLabel)
            $0.top.equalTo(self.helpTitleLabel.snp.bottom).offset(10)
        }
        
        self.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints {
            $0.edges.equalTo(self.titlePlaceHolderLabel)
        }
        self.titleLabel.isHidden = true
        
        self.addSubview(self.underLineView)
        self.underLineView.snp.makeConstraints {
            $0.leading.trailing.equalTo(self.helpTitleLabel)
            $0.height.equalTo(1)
            $0.top.equalTo(self.titlePlaceHolderLabel.snp.bottom).offset(6)
        }
    }
    
    private func setRegistedTitleUI(title: String) {
        self.titleLabel.text = title
        self.titleLabel.isHidden = false
        self.titlePlaceHolderLabel.isHidden = true
        self.underLineView.isHidden = true
    }
    
    private func setUnRegistedTitleUI() {
        self.titleLabel.isHidden = true
        self.titlePlaceHolderLabel.isHidden = false
        self.underLineView.isHidden = false
    }
    
    @objc private func regist(_ recognizer: UITapGestureRecognizer) {
        self.delegate?.clickedRegistTitle?()
    }
    
    // MARK: func
    
    func setRegistTitle(_ title: String) {
        if title == "" {
            DispatchQueue.main.async { [weak self] in
                self?.setUnRegistedTitleUI()
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.setRegistedTitleUI(title: title)
            }
        }
    }

}

class RegistForegroundBottomViewDelegateProxy: DelegateProxy<RegistForegroundBottomView, RegistForegroundBottomViewDelegate>, DelegateProxyType, RegistForegroundBottomViewDelegate {
    
    
    static func currentDelegate(for object: RegistForegroundBottomView) -> RegistForegroundBottomViewDelegate? {
        return object.delegate
    }
    
    static func setCurrentDelegate(_ delegate: RegistForegroundBottomViewDelegate?, to object: RegistForegroundBottomView) {
        object.delegate = delegate
    }
    
    static func registerKnownImplementations() {
        self.register { (view) -> RegistForegroundBottomViewDelegateProxy in
            RegistForegroundBottomViewDelegateProxy(parentObject: view, delegateProxy: self)
        }
    }
}

extension Reactive where Base: RegistForegroundBottomView {
    var delegate: DelegateProxy<RegistForegroundBottomView, RegistForegroundBottomViewDelegate> {
        return RegistForegroundBottomViewDelegateProxy.proxy(for: self.base)
    }
    
    var clickedRegistTitle: Observable<Void> {
        return delegate.methodInvoked(#selector(RegistForegroundBottomViewDelegate.clickedRegistTitle))
            .map { result in
                return ()
            }
    }
}

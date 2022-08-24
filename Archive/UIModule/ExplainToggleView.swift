//
//  ExplainToggleView.swift
//  Archive
//
//  Created by hanwe on 2022/08/24.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

@objc protocol ExplainToggleViewDelegate: AnyObject {
    @objc optional func toggleState(_ view: ExplainToggleView, isOn: Bool)
}

class ExplainToggleView: UIView {
    
    // MARK: UIProperty
    
    private lazy var titleLabel = UILabel().then {
        $0.font = .fonts(.subTitle)
        $0.textColor = Gen.Colors.black.color
        $0.text = self.titleText
    }
    
    private let toggle = UISwitch().then {
        $0.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
    }
    
    private lazy var helpLabel = UILabel().then {
        $0.font = .fonts(.caption)
        $0.textColor = Gen.Colors.gray03.color
        $0.text = self.helpText
    }
    
    // MARK: private property
    
    // MARK: internal property
    
    var titleText: String {
        didSet {
            self.titleLabel.text = self.titleText
        }
    }
    
    var helpText: String {
        didSet {
            self.helpLabel.text = self.helpText
        }
    }
    
    var toggleTintColor: UIColor {
        didSet {
            self.toggle.tintColor = self.toggleTintColor
        }
    }
    
    var toggleOnTintColor: UIColor {
        didSet {
            self.toggle.onTintColor = self.toggleOnTintColor
        }
    }
    
    weak var delegate: ExplainToggleViewDelegate?
    
    // MARK: lifeCycle
    
    init(titleText: String = "", helpText: String = "", toggleTintColor: UIColor = .gray, toggleOnTintColor: UIColor = .black) {
        self.titleText = titleText
        self.helpText = helpText
        self.toggleTintColor = toggleTintColor
        self.toggleOnTintColor = toggleOnTintColor
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: private function
    
    private func setup() {
        
        self.addSubview(self.toggle)
        self.toggle.snp.makeConstraints {
            $0.top.trailing.equalTo(self)
        }
        toggle.addTarget(self, action: #selector(switchValueDidChange(_:)), for: .valueChanged)
        
        self.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints {
            $0.centerY.equalTo(self.toggle)
            $0.leading.equalTo(self)
            $0.trailing.equalTo(self.toggle)
        }
        
        self.addSubview(self.helpLabel)
        self.helpLabel.snp.makeConstraints {
            $0.leading.trailing.bottom.equalTo(self)
            $0.top.equalTo(self.titleLabel.snp.bottom).offset(13)
        }
    }
    
    @objc func switchValueDidChange(_ sender: UISwitch) {
        self.delegate?.toggleState?(self, isOn: self.toggle.isOn)
    }
    
    // MARK: internal function
    
}

class ExplainToggleViewDelegateProxy: DelegateProxy<ExplainToggleView, ExplainToggleViewDelegate>, DelegateProxyType, ExplainToggleViewDelegate {
    
    
    static func currentDelegate(for object: ExplainToggleView) -> ExplainToggleViewDelegate? {
        return object.delegate
    }
    
    static func setCurrentDelegate(_ delegate: ExplainToggleViewDelegate?, to object: ExplainToggleView) {
        object.delegate = delegate
    }
    
    static func registerKnownImplementations() {
        self.register { (view) -> ExplainToggleViewDelegateProxy in
            ExplainToggleViewDelegateProxy(parentObject: view, delegateProxy: self)
        }
    }
}

extension Reactive where Base: ExplainToggleView {
    var delegate: DelegateProxy<ExplainToggleView, ExplainToggleViewDelegate> {
        return ExplainToggleViewDelegateProxy.proxy(for: self.base)
    }
    
    var toggleState: Observable<Bool> {
        return delegate.methodInvoked(#selector(ExplainToggleViewDelegate.toggleState(_:isOn:)))
            .map { result in
                return result[1] as? Bool ?? false
            }
    }
}

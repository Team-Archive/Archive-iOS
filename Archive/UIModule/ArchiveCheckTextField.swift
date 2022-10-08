//
//  ArchiveCheckTextField.swift
//  Archive
//
//  Created by hanwe on 2022/08/06.
//

import UIKit
import SnapKit
import Then
import RxCocoa
import RxSwift

@objc protocol ArchiveCheckTextFieldDelegate: AnyObject {
    @objc optional func changeState(_ view: ArchiveCheckTextField, isActive: Bool)
    @objc optional func checkClicked(_ view: ArchiveCheckTextField, checkText: String)
    @objc optional func changedText(_ view: ArchiveCheckTextField, text: String)
}

class ArchiveCheckTextField: UIView {

    // MARK: UI property
    
    private lazy var containerView = UIView().then {
        $0.backgroundColor = Gen.Colors.white.color
        $0.layer.borderWidth = 1
        $0.layer.borderColor = self.disableColor.cgColor
        $0.layer.cornerRadius = 8
    }
    
    private let checkBtnContainerView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private lazy var checkBtn = UIButton().then {
        $0.isEnabled = false
        $0.backgroundColor = .clear
        $0.titleLabel?.font = .fonts(.button)
        $0.setTitleAllState(self.checkBtnTitle)
        $0.setTitleColor(self.disableColor, for: .disabled)
        $0.setTitleColor(self.enableColor, for: .normal)
        $0.setTitleColor(Gen.Colors.gray03.color, for: .highlighted)
        $0.addTarget(self, action: #selector(checkClicked), for: .touchUpInside)
    }
    
    private lazy var checkBtnUnderlineView = UIView().then {
        $0.backgroundColor = self.disableColor
    }
    
    private lazy var textField = UITextField().then {
        $0.backgroundColor = .clear
        $0.placeholder = self.placeHolderText
        $0.font = .fonts(.body)
        $0.textColor = Gen.Colors.gray02.color
        $0.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    // MARK: private property
    
    private let checkBtnTitle: String
    private let placeHolderText: String
    private let originValue: String
    
    private let enableColor = Gen.Colors.black.color
    private let disableColor = Gen.Colors.gray04.color
    
    // MARK: internal property
    
    weak var delegate: ArchiveCheckTextFieldDelegate?
    
    private(set) var isActive: Bool = false {
        didSet {
            if self.isActive {
                DispatchQueue.main.async { [weak self] in
                    self?.setActiveUI()
                    self?.delegate?.changeState?(self ?? ArchiveCheckTextField(originValue: "", placeHolder: "", checkBtnTitle: ""), isActive: true)
                }
            } else {
                DispatchQueue.main.async { [weak self] in
                    self?.setInActiveUI()
                    self?.delegate?.changeState?(self ?? ArchiveCheckTextField(originValue: "", placeHolder: "", checkBtnTitle: ""), isActive: false)
                }
            }
        }
    }
    
    var text: String? {
        return self.textField.text
    }
    
    // MARK: lifeCycle
    
    init(originValue: String, placeHolder: String, checkBtnTitle: String) {
        self.placeHolderText = placeHolder
        self.checkBtnTitle = checkBtnTitle
        self.originValue = originValue
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: private function
    
    private func setup() {
        self.addSubview(self.containerView)
        self.containerView.snp.makeConstraints {
            $0.edges.equalTo(self)
        }
        
        self.containerView.addSubview(self.checkBtnContainerView)
        self.checkBtnContainerView.snp.makeConstraints {
            $0.centerY.equalTo(self.containerView.snp.centerY)
            $0.trailing.equalTo(self.containerView.snp.trailing).offset(-20)
        }
        
        self.checkBtnContainerView.addSubview(self.checkBtn)
        self.checkBtn.snp.makeConstraints {
            $0.leading.trailing.top.equalTo(self.checkBtnContainerView)
            $0.width.equalTo(self.checkBtnTitle.width(withConstrainedHeight: 1, font: self.checkBtn.titleLabel?.font ?? .fonts(.button)))
        }
        
        self.checkBtnContainerView.addSubview(self.checkBtnUnderlineView)
        self.checkBtnUnderlineView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalTo(self.checkBtnContainerView)
            $0.height.equalTo(1)
            $0.top.equalTo(self.checkBtn.snp.bottom)
        }
        
        self.containerView.addSubview(self.textField)
        self.textField.snp.makeConstraints {
            $0.leading.equalTo(self.containerView).offset(20)
            $0.trailing.equalTo(self.checkBtnContainerView.snp.leading).offset(-12)
            $0.height.equalTo(21)
            $0.centerY.equalTo(self.containerView.snp.centerY)
        }
    }
    
    // MARK: private function
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else {
            setInActiveUI()
            self.delegate?.changeState?(self, isActive: false)
            return
        }
        if text == self.originValue || text == "" {
            setInActiveUI()
            self.delegate?.changeState?(self, isActive: false)
        } else {
            setActiveUI()
            self.delegate?.changeState?(self, isActive: true)
        }
        self.delegate?.changedText?(self, text: textField.text ?? "")
    }
    
    private func setActiveUI() {
        self.checkBtn.isEnabled = true
        self.containerView.layer.borderColor = self.enableColor.cgColor
        self.checkBtnUnderlineView.backgroundColor = self.enableColor
    }
    
    private func setInActiveUI() {
        self.checkBtn.isEnabled = false
        self.containerView.layer.borderColor = self.disableColor.cgColor
        self.checkBtnUnderlineView.backgroundColor = self.disableColor
    }
    
    @objc private func checkClicked() {
        self.delegate?.checkClicked?(self, checkText: self.textField.text ?? "")
    }
    
    // MARK: function

}

class ArchiveCheckTextFieldDelegateProxy: DelegateProxy<ArchiveCheckTextField, ArchiveCheckTextFieldDelegate>, DelegateProxyType, ArchiveCheckTextFieldDelegate {
    
    
    static func currentDelegate(for object: ArchiveCheckTextField) -> ArchiveCheckTextFieldDelegate? {
        return object.delegate
    }
    
    static func setCurrentDelegate(_ delegate: ArchiveCheckTextFieldDelegate?, to object: ArchiveCheckTextField) {
        object.delegate = delegate
    }
    
    static func registerKnownImplementations() {
        self.register { (view) -> ArchiveCheckTextFieldDelegateProxy in
            ArchiveCheckTextFieldDelegateProxy(parentObject: view, delegateProxy: self)
        }
    }
}

extension Reactive where Base: ArchiveCheckTextField {
    var delegate: DelegateProxy<ArchiveCheckTextField, ArchiveCheckTextFieldDelegate> {
        return ArchiveCheckTextFieldDelegateProxy.proxy(for: self.base)
    }
    
    var isActiveState: Observable<Bool> {
        return delegate.methodInvoked(#selector(ArchiveCheckTextFieldDelegate.changeState(_:isActive:)))
            .map { result in
                return result[1] as? Bool ?? false
            }
    }
    
    var check: Observable<String> {
        return delegate.methodInvoked(#selector(ArchiveCheckTextFieldDelegate.checkClicked(_:checkText:)))
            .map { result in
                return result[1] as? String ?? ""
            }
    }
    
    var text: Observable<String> {
        return delegate.methodInvoked(#selector(ArchiveCheckTextFieldDelegate.changedText(_:text:)))
            .map { result in
                return result[1] as? String ?? ""
            }
    }
}

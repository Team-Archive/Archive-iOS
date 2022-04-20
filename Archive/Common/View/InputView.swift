//
//  InputView.swift
//  Archive
//
//  Created by TTOzzi on 2021/10/16.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class InputView: UIView, UITextFieldDelegate {
    
    private enum Constants {
        static let cornerRadius: CGFloat = 8
        static let borderWidth: CGFloat = 1
        static let horizontalPadding: CGFloat = 20
        static let contentStackViewSpacing: CGFloat = 12
    }
    
    private enum Styles {
        static let placeholderColor = Gen.Colors.gray03.color
        static let borderColor = Gen.Colors.gray04.color
        static let focusedBorderColor = UIColor.black
    }
    
    var placeholder: String? {
        get { textField.placeholder }
        set {
            guard let newValue = newValue else {
                textField.attributedPlaceholder = nil
                return
            }
            let attributes = [NSAttributedString.Key.foregroundColor: Styles.placeholderColor]
            textField.attributedPlaceholder = NSAttributedString(string: newValue, attributes: attributes)
        }
    }
    var isSecureTextEntry: Bool {
        get { textField.isSecureTextEntry }
        set { textField.isSecureTextEntry = newValue }
    }
    var rightButtonTitle: String {
        get { rightButton.attributedTitle(for: .normal)?.string ?? "" }
        set {
            setupRightButton(with: newValue)
            rightButton.isHidden = false
        }
    }
    var returnKeyType: UIReturnKeyType = .default {
        didSet {
            self.textField.returnKeyType = self.returnKeyType
        }
    }
    
    fileprivate lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = Constants.contentStackViewSpacing
        return stackView
    }()
    fileprivate lazy var textField: UITextField = {
        let textField = UITextField()
        textField.font = .fonts(.body)
        textField.delegate = self
        return textField
    }()
    fileprivate lazy var rightButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .fonts(.button)
        button.isHidden = true
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        return button
    }()
    private var disposeBag = DisposeBag()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupAttributes()
        setupLayouts()
    }
    
    private func setupAttributes() {
        self.backgroundColor = Gen.Colors.white.color
        layer.cornerRadius = Constants.cornerRadius
        layer.borderWidth = Constants.borderWidth
        layer.borderColor = Styles.borderColor.cgColor
        
        textField.rx.controlEvent(.editingDidBegin)
            .map { Styles.focusedBorderColor.cgColor }
            .bind(to: layer.rx.borderColor)
            .disposed(by: disposeBag)
        
        textField.rx.controlEvent(.editingDidEnd)
            .map { Styles.borderColor.cgColor }
            .bind(to: layer.rx.borderColor)
            .disposed(by: disposeBag)
    }
    
    private func setupLayouts() {
        addSubview(contentStackView)
        contentStackView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.top.bottom.greaterThanOrEqualToSuperview()
            $0.leading.trailing.equalToSuperview().inset(Constants.horizontalPadding)
        }
        contentStackView.addArrangedSubview(textField)
        contentStackView.addArrangedSubview(rightButton)
    }
    
    private func setupRightButton(with title: String) {
        let normalAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
                                                               NSAttributedString.Key.foregroundColor: UIColor.black]
        let normalAttributedString = NSMutableAttributedString(string: title, attributes: normalAttributes)
        rightButton.setAttributedTitle(normalAttributedString, for: .normal)
        let highlightedAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
                                                                 NSAttributedString.Key.foregroundColor: Gen.Colors.gray03.color]
        let highlightedAttributedString = NSMutableAttributedString(string: title, attributes: highlightedAttributes)
        rightButton.setAttributedTitle(highlightedAttributedString, for: .highlighted)
        let disabledAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
                                                                 NSAttributedString.Key.foregroundColor: Gen.Colors.gray04.color]
        let disabledAttributedString = NSMutableAttributedString(string: title, attributes: disabledAttributes)
        rightButton.setAttributedTitle(disabledAttributedString, for: .disabled)
    }
    
    func focusTextField() {
        textField.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension Reactive where Base: InputView {
    var text: ControlProperty<String?> {
        return base.textField.rx.text
    }
    var editingDidEndOnExit: ControlEvent<Void> {
        return base.textField.rx.controlEvent(.editingDidEndOnExit)
    }
    var tapRightButton: ControlEvent<Void> {
        return base.rightButton.rx.tap
    }
    var isEnabledRightButton: Binder<Bool> {
        return base.rightButton.rx.isEnabled
    }
}

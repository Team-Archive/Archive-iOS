//
//  ClearTextField.swift
//  Archive
//
//  Created by hanwe on 2022/08/23.
//

import UIKit
import Then
import SnapKit
import RxSwift
import RxCocoa

@objc protocol ClearTextFieldDelegate: AnyObject {
    @objc optional func didSelecteDate(_ view: ClearTextField, date: String)
    @objc optional func doneClicked(_ view: ClearTextField, text: String)
    @objc optional func didEndEditing(_ view: ClearTextField, text: String)
}

class ClearTextField: UIView {
    
    private let mainContentsView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private lazy var textField = UITextField().then {
        $0.backgroundColor = .clear
        $0.font = .fonts(.header2)
        $0.textColor = self.selectedColor
        $0.delegate = self
        $0.returnKeyType = .done
        $0.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    private lazy var unselectedUnderlineView = UIView().then {
        $0.backgroundColor = self.unselectedColor
    }
    
    private lazy var selectedUnderlineView = UIView().then {
        $0.backgroundColor = self.selectedColor
    }
    
    private lazy var clearBtn = UIButton().then {
        $0.setImageAllState(Gen.Images.btnCancel.image)
        $0.addTarget(self, action: #selector(clearAction), for: .touchUpInside)
    }
    
    // MARK: private property
    
    private let unselectedColor = Gen.Colors.gray04.color
    private let selectedColor = Gen.Colors.black.color
    private var datePicker: UIDatePicker
    
    private let disposeBag = DisposeBag()

    // MARK: internal property
    
    var placeholder: String = "" {
        didSet {
            self.textField.attributedPlaceholder = NSAttributedString(
                string: self.placeholder,
                attributes: [NSAttributedString.Key.font: UIFont.fonts(.header2), NSAttributedString.Key.foregroundColor: Gen.Colors.gray032.color]
            )
        }
    }
    
    weak var delegate: ClearTextFieldDelegate?
    
    // MARK: lifeCycle
    
    init(isDatePicker: Bool = false) {
        self.datePicker = UIDatePicker.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 200))
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        setup()
        if isDatePicker {
            makeDataPicker()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: private function
    
    private func setup() {
        self.addSubview(self.mainContentsView)
        self.mainContentsView.snp.makeConstraints {
            $0.edges.equalTo(self)
        }
        
        self.mainContentsView.addSubview(self.unselectedUnderlineView)
        self.unselectedUnderlineView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalTo(self.mainContentsView)
            $0.height.equalTo(1)
        }
        self.mainContentsView.addSubview(self.selectedUnderlineView)
        self.selectedUnderlineView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalTo(self.mainContentsView)
            $0.height.equalTo(2)
        }
        self.selectedUnderlineView.isHidden = true
        
        
        self.mainContentsView.addSubview(self.clearBtn)
        self.clearBtn.snp.makeConstraints {
            $0.trailing.top.equalTo(self.mainContentsView)
            $0.bottom.equalTo(self.selectedUnderlineView.snp.top)
            $0.width.equalTo(48)
        }
        self.clearBtn.isHidden = true
        
        self.mainContentsView.addSubview(self.textField)
        self.textField.snp.makeConstraints {
            $0.leading.top.equalTo(self.mainContentsView)
            $0.trailing.trailing.equalTo(self.clearBtn.snp.leading)
            $0.bottom.equalTo(self.selectedUnderlineView.snp.top)
        }
    }
    
    private func refreshFocusUI() {
        self.selectedUnderlineView.isHidden = false
    }
    
    private func refreshUnfocusUI() {
        self.selectedUnderlineView.isHidden = true
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        if textField.text == "" || textField.text == nil {
            self.clearBtn.isHidden = true
        } else {
            self.clearBtn.isHidden = false
        }
    }
    
    @objc private func clearAction() {
        self.textField.text = ""
        self.clearBtn.isHidden = true
    }
    
    private func makeDataPicker() {
        self.datePicker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            self.datePicker.preferredDatePickerStyle = .wheels
        }
        self.textField.inputView = datePicker
        let doneButton = UIBarButtonItem.init(title: "완료", style: .done, target: self, action: #selector(self.datePickerDone))
        let toolBar = UIToolbar.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        toolBar.setItems([UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil), doneButton], animated: true)
        self.textField.inputAccessoryView = toolBar
    }
    
    @objc private func datePickerDone() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy/MM/dd"
        self.textField.text = dateFormatter.string(from: datePicker.date)
        self.delegate?.didSelecteDate?(self, date: dateFormatter.string(from: datePicker.date))
        self.textField.resignFirstResponder()
    }
    
    // MARK: internal function
    
    override func becomeFirstResponder() -> Bool {
        self.textField.becomeFirstResponder()
        return true
    }
    

}

extension ClearTextField: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        refreshFocusUI()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        refreshUnfocusUI()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.endEditing(true)
        self.delegate?.doneClicked?(self, text: textField.text ?? "")
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        self.delegate?.didEndEditing?(self, text: textField.text ?? "")
    }
}

class ClearTextFieldDelegateProxy: DelegateProxy<ClearTextField, ClearTextFieldDelegate>, DelegateProxyType, ClearTextFieldDelegate {
    
    
    static func currentDelegate(for object: ClearTextField) -> ClearTextFieldDelegate? {
        return object.delegate
    }
    
    static func setCurrentDelegate(_ delegate: ClearTextFieldDelegate?, to object: ClearTextField) {
        object.delegate = delegate
    }
    
    static func registerKnownImplementations() {
        self.register { (view) -> ClearTextFieldDelegateProxy in
            ClearTextFieldDelegateProxy(parentObject: view, delegateProxy: self)
        }
    }
}

extension Reactive where Base: ClearTextField {
    var delegate: DelegateProxy<ClearTextField, ClearTextFieldDelegate> {
        return ClearTextFieldDelegateProxy.proxy(for: self.base)
    }
    
    var didSelectedDate: Observable<String> {
        return delegate.methodInvoked(#selector(ClearTextFieldDelegate.didSelecteDate(_:date:)))
            .map { result in
                return result[1] as? String ?? ""
            }
    }
    
    var doneButtonClicked: Observable<String> {
        return delegate.methodInvoked(#selector(ClearTextFieldDelegate.doneClicked(_:text:)))
            .map { result in
                return result[1] as? String ?? ""
            }
    }
    
    var didEndEditing: Observable<String> {
        return delegate.methodInvoked(#selector(ClearTextFieldDelegate.didEndEditing(_:text:)))
            .map { result in
                return result[1] as? String ?? ""
            }
    }
}

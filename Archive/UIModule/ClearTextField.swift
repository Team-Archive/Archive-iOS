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

class ClearTextField: UIView {
    
    private let mainContentsView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private lazy var textField = UITextField().then {
        $0.backgroundColor = .clear
        $0.font = .fonts(.header2)
        $0.textColor = self.selectedColor
        $0.placeholder = "전시명을 입력해주세요."
        $0.delegate = self
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
    
    private let disposeBag = DisposeBag()

    // MARK: internal property
    
    // MARK: lifeCycle
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        setup()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: private function
    
    private func setup() {
        self.addSubview(self.mainContentsView)
        self.mainContentsView.snp.makeConstraints {
            $0.edges.equalTo(self.mainContentsView)
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
    
    // MARK: internal function
    

}

extension ClearTextField: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        refreshFocusUI()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        refreshUnfocusUI()
    }
}

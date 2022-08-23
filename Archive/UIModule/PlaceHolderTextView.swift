//
//  PlaceHolderTextView.swift
//  Archive
//
//  Created by hanwe on 2022/08/20.
//

import UIKit
import SnapKit
import Then

protocol PlaceHolderTextViewDelegate: AnyObject {
    func textViewDidChange(_ textView: PlaceHolderTextView, text: String)
}

class PlaceHolderTextView: UIView {

    // MARK: private UI property
    
    private let textView = UITextView().then {
        $0.backgroundColor = .clear
    }
    
    // MARK: internal UI property
    
    // MARK: private property
    
    // MARK: property
    
    var placeHolder: String = "" {
        didSet {
            let text = self.placeHolder
            DispatchQueue.main.async { [weak self] in
                self?.refreshPlaceHolder(text)
            }
        }
    }
    
    var font: UIFont? {
        didSet {
            guard let font = font else { return }
            DispatchQueue.main.async { [weak self] in
                self?.textView.font = font
            }
        }
    }
    
    var textColor: UIColor = .black {
        didSet {
            let color = self.textColor
            DispatchQueue.main.async { [weak self] in
                self?.textView.textColor = color
            }
        }
    }
    
    var text: String = "" {
        didSet {
            let text = text
            DispatchQueue.main.async { [weak self] in
                if text != "" {
                    self?.textView.text = text
                } else {
                    print("use clearText method")
                }
            }
        }
    }
    
    var customInputAccessoryView: UIView? {
        didSet {
            self.textView.inputAccessoryView = self.customInputAccessoryView
        }
    }
    
    weak var delegate: PlaceHolderTextViewDelegate?
    
    // MARK: lifeCycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: private func
    
    private func setup() {
        self.addSubview(self.textView)
        self.textView.snp.makeConstraints {
            $0.edges.equalTo(self)
        }
        self.textView.delegate = self
        
    }
    
    private func refreshPlaceHolder(_ text: String) {
        if self.textView.text == "" {
            self.textView.text = self.placeHolder
            self.textView.textColor = Gen.Colors.gray02.color
        }
    }
    
    // MARK: func
    
    func clearText() {
        DispatchQueue.main.async { [weak self] in
            self?.text = ""
            self?.textView.text = self?.placeHolder
            self?.textView.textColor = Gen.Colors.gray02.color
        }
    }

}

extension PlaceHolderTextView: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if self.textView.text == self.placeHolder {
            DispatchQueue.main.async { [weak self] in
                self?.textView.text = nil
                self?.textView.textColor = Gen.Colors.black.color
            }
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if self.textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            DispatchQueue.main.async { [weak self] in
                self?.textView.text = self?.placeHolder
                self?.textView.textColor = Gen.Colors.gray02.color
            }
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.delegate?.textViewDidChange(self, text: textView.text ?? "")
        self.text = textView.text ?? ""
    }
}

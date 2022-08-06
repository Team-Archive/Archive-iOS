//
//  ArchiveConfirmButton.swift
//  Archive
//
//  Created by hanwe on 2022/08/06.
//

import UIKit

class ArchiveConfirmButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    var buttonColor: UIColor = Gen.Colors.black.color {
        didSet {
            DispatchQueue.main.async { [weak self] in
                    self?.setBackgroundColor(self?.buttonColor ?? Gen.Colors.black.color, for: .normal)
                    self?.setBackgroundColor(self?.buttonColor ?? Gen.Colors.black.color, for: .focused)
                    self?.setBackgroundColor(self?.buttonColor ?? Gen.Colors.black.color, for: .selected)
            }
        }
    }
    
    var disableButtonColor: UIColor = Gen.Colors.gray04.color {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.setBackgroundColor(self?.disableButtonColor ?? Gen.Colors.gray04.color, for: .disabled)
            }
        }
    }
    
    var titleColor: UIColor = Gen.Colors.white.color {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.setTitleColor(self?.titleColor ?? Gen.Colors.black.color, for: .normal)
                self?.setTitleColor(self?.titleColor ?? Gen.Colors.black.color, for: .focused)
                self?.setTitleColor(self?.titleColor ?? Gen.Colors.black.color, for: .selected)
            }
        }
    }
    
    var disableTitleColor: UIColor = Gen.Colors.white.color {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.setTitleColor(self?.disableTitleColor ?? Gen.Colors.white.color, for: .disabled)
            }
        }
    }
    
    var titleFont: UIFont = .fonts(.button) {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.titleLabel?.font = self?.titleFont ?? .fonts(.button)
            }
        }
    }
    
    private func setup() {
        self.titleLabel?.font = self.titleFont
        
        self.setBackgroundColor(self.buttonColor, for: .normal)
        self.setBackgroundColor(self.buttonColor, for: .focused)
        self.setBackgroundColor(self.buttonColor, for: .selected)
        self.setBackgroundColor(self.disableButtonColor, for: .disabled)
        
        self.setTitleColor(self.titleColor, for: .normal)
        self.setTitleColor(self.titleColor, for: .focused)
        self.setTitleColor(self.titleColor, for: .selected)
        self.setTitleColor(self.disableTitleColor, for: .disabled)
        self.clipsToBounds = true
        self.layer.cornerRadius = 8
    }
    
}


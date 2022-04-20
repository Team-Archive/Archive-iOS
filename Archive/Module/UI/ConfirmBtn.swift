//
//  ConfirmBtn.swift
//  Archive
//
//  Created by hanwe on 2022/04/16.
//

import UIKit

class ConfirmBtn: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        
        self.titleLabel?.font = .fonts(.button)
        
        if #available(iOS 15.0, *) {
            self.configuration = .filled()
            self.configuration?.baseBackgroundColor = Gen.Colors.black.color
        } else {
            self.setBackgroundColor(Gen.Colors.black.color, for: .normal)
            self.setBackgroundColor(Gen.Colors.black.color, for: .focused)
            self.setBackgroundColor(Gen.Colors.black.color, for: .selected)
            self.setBackgroundColor(Gen.Colors.gray05.color, for: .disabled)
        }
        
        self.setTitleColor(Gen.Colors.white.color, for: .normal)
        self.setTitleColor(Gen.Colors.white.color, for: .focused)
        self.setTitleColor(Gen.Colors.white.color, for: .selected)
        self.setTitleColor(Gen.Colors.gray05.color, for: .highlighted)
        self.layer.cornerRadius = 8
        self.clipsToBounds = true
    }
}

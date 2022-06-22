//
//  ImageButton.swift
//  Archive
//
//  Created by hanwe on 2022/06/22.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then

class ImageButton: UIButton {

    // MARK: UI property
    
    // MARK: private property
    
    // MARK: internal property
    
    var buttonTitle: String = "" {
        didSet {
            self.setTitleAllState(self.buttonTitle)
        }
    }
    
    var buttonTitleFont: UIFont = .fonts(.button) {
        didSet {
            self.titleLabel?.font = self.buttonTitleFont
        }
    }
    
    var buttonImage: UIImage = UIImage() {
        didSet {
            self.setImageAllState(self.buttonImage)
        }
    }
    
    // MARK: lifeCycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: private function
    
    private func setup() {
        self.setImageAllState(self.buttonImage)
        self.setTitleAllState(self.buttonTitle)
        self.titleLabel?.font = self.buttonTitleFont
        self.setTitleColor(Gen.Colors.black.color, for: .selected)
        self.setTitleColor(Gen.Colors.gray03.color, for: .highlighted)
        self.setTitleColor(Gen.Colors.black.color, for: .focused)
        self.setTitleColor(Gen.Colors.black.color, for: .normal)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if imageView != nil {
            imageEdgeInsets = UIEdgeInsets(top: 5, left: (bounds.width - 35), bottom: 5, right: 5)
            titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: (imageView?.frame.width) ?? 0)
        }
    }
    
    // MARK: function
    
}

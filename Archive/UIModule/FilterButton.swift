//
//  FilterButton.swift
//  Archive
//
//  Created by hanwe on 2022/06/22.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then

//@objc protocol FilterButtonDelegate: AnyObject {
//
//}

class FilterButton: UIButton {

    // MARK: UI property
    
//    private let mainContentsView = UIView().then {
//        $0.backgroundColor = Gen.Colors.white.color
//    }
    
    
    
    // MARK: private property
    
    // MARK: internal property
    
//    weak var delegate: FilterButtonDelegate?
    
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
//        self.addSubview(self.mainContentsView)
//        self.mainContentsView.snp.makeConstraints {
//            $0.edges.equalTo(self.snp.edges)
//        }
        
//        self.imageView?.image = Gen.Images.coverShame.image
        self.setImageAllState(Gen.Images.filter.image)
        self.setTitleAllState("필터")
        self.titleLabel?.font = .fonts(.button)
        self.setTitleColor(Gen.Colors.black.color, for: .selected)
        self.setTitleColor(Gen.Colors.black.color, for: .highlighted)
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

//
//  ForegroundStep1TopView.swift
//  Archive
//
//  Created by hanwe on 2022/08/15.
//

import UIKit
import Then
import SnapKit

class ForegroundStep1TopView: UIView {

    // MARK: private UI property
    
    private let mainContentsView = UIView().then {
        $0.backgroundColor = Gen.Colors.gray04.color
    }
    
    private let foregroundTopPlaceHolderImgView = UIImageView().then {
        $0.image = Gen.Images.defaultEmotionMain.image
    }
    
    private let upIconImgView = UIImageView().then {
        $0.image = Gen.Images.iconDropUp.image
    }
    
    // MARK: internal UI property
    
    // MARK: property
    
    // MARK: private Property
    
    // MARK: lifeCycle
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        setup()
    }
    
    // MARK: private func
    
    private func setup() {
        self.backgroundColor = .clear
        
        self.addSubview(self.mainContentsView)
        self.mainContentsView.snp.makeConstraints {
            $0.edges.equalTo(self)
        }
        
        self.mainContentsView.addSubview(self.foregroundTopPlaceHolderImgView)
        self.foregroundTopPlaceHolderImgView.snp.makeConstraints {
            $0.leading.equalTo(self.mainContentsView).offset(32)
            $0.trailing.equalTo(self.mainContentsView).offset(-32)
            $0.height.equalTo(UIScreen.main.bounds.width - 64)
            $0.bottom.equalTo(self.mainContentsView).offset(-75)
        }
        
        self.mainContentsView.addSubview(self.upIconImgView)
        self.upIconImgView.snp.makeConstraints {
            $0.width.height.equalTo(44)
            $0.bottom.equalTo(self.mainContentsView)
            $0.centerX.equalTo(self.mainContentsView)
        }
    }
    
    // MARK: func

}

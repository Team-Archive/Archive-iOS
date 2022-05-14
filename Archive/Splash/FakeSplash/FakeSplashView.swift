//
//  FakeSplashView.swift
//  Archive
//
//  Created by hanwe on 2022/05/14.
//

import UIKit
import Then

class FakeSplashView: UIView {
    
    // MARK: private UI property
    
    private let mainContentsView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private let splashImgView = UIImageView().then {
        $0.image = Gen.Images.splash.image
    }
    
    // MARK: private property
    
    // MARK: property
    
    // MARK: lifeCycle
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        setUp()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: private func
    
    private func setUp() {
        
        self.addSubview(self.mainContentsView)
        self.mainContentsView.snp.makeConstraints {
            $0.edges.equalTo(self)
        }
        
        self.addSubview(self.splashImgView)
        self.splashImgView.snp.makeConstraints {
            $0.edges.equalTo(self)
        }
    }
    
    // MARK: func
    
}

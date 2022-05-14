//
//  FakeSplashView.swift
//  Archive
//
//  Created by hanwe on 2022/05/14.
//

import UIKit

class FakeSplashView: UIView, NibIdentifiable {
    
    // MARK: outlet
//    @IBOutlet weak var mainBackgroundView: UIView!
    
    // MARK: private property
    
    // MARK: property
    
    // MARK: lifeCycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initUI()
    }
    
    // MARK: private func
    
    private func initUI() {
//        self.mainBackgroundView.backgroundColor = Gen.Colors.white.color 테스트 주석
//        self.mainBackgroundView.backgroundColor = .lightGray
    }
    
    // MARK: func
    
    class func instance() -> FakeSplashView? {
        return nib.instantiate(withOwner: nil, options: nil).first as? FakeSplashView
    }
    
    // MARK: action
    
    
    
    

}

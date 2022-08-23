//
//  RegistBehindView.swift
//  Archive
//
//  Created by hanwe on 2022/08/23.
//

import UIKit
import SnapKit
import Then

class RegistBehindView: UIView {
    
    // MARK: UIProperty
    
    private let mainBackgroundView = UIView().then {
        $0.backgroundColor = Gen.Colors.white.color
    }
    
    private let scrollContainerView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private let scrollView = UIScrollView().then {
        $0.backgroundColor = .clear
    }
    
    private let mainContentsView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private let archiveNameLabel = UILabel().then {
        $0.font = .fonts(.subTitle)
        $0.textColor = Gen.Colors.black.color
        $0.text = "무슨 전시를 감상했나요?*"
    }
    
    private let archiveNameTextField = ClearTextField().then {
        $0.placeholder = "전시명을 입력해주세요."
    }
    
    private let whenLabel = UILabel().then {
        $0.font = .fonts(.subTitle)
        $0.textColor = Gen.Colors.black.color
        $0.text = "언제 전시를 감상했나요?*"
    }
    
    private let whenTextField = ClearTextField().then {
        $0.placeholder = "YY/MM/DD"
    }
    
    private let friendsLabel = UILabel().then {
        $0.font = .fonts(.subTitle)
        $0.textColor = Gen.Colors.black.color
        $0.text = "누구와 관람하셨나요?"
    }
    
    private let friendsTextField = ClearTextField().then {
        $0.placeholder = "동행인은 쉼표로 구분됩니다."
    }
    
    // MARK: private property
    
    // MARK: internal property
    
    // MARK: lifeCycle
    
    // MARK: private function
    
    // MARK: internal function
    

}

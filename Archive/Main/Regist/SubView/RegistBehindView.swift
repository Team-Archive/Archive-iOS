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
    
    private let topGradationView = UIImageView().then {
        $0.backgroundColor = .clear
        $0.image = Gen.Images.navigationGradation.image
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
    
    private var topView = UIView().then {
        $0.backgroundColor = Emotion.pleasant.color
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
    
    private let whenTextField = ClearTextField(isDatePicker: true).then {
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
    
    private let navigationHeight: CGFloat
    
    // MARK: internal property
    
    var emotion: Emotion? {
        didSet {
            guard let emotion = emotion else { return }
            DispatchQueue.main.async { [weak self] in
                self?.topView.backgroundColor = emotion.color
            }
        }
    }
    
    // MARK: lifeCycle
    
    init(navigationHeight: CGFloat) {
        self.navigationHeight = navigationHeight
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: private function
    
    private func setup() {
        self.addSubview(self.mainBackgroundView)
        self.mainBackgroundView.snp.makeConstraints {
            $0.edges.equalTo(self)
        }
        
        self.addSubview(self.scrollContainerView)
        self.scrollContainerView.snp.makeConstraints {
            $0.edges.equalTo(self)
        }
        
        self.scrollContainerView.addSubview(self.scrollView)
        self.scrollView.snp.makeConstraints {
            $0.edges.equalTo(self.scrollContainerView)
        }
        
        self.scrollView.addSubview(self.mainContentsView)
        self.mainContentsView.snp.makeConstraints {
            $0.edges.equalTo(self.scrollView).priority(750)
            $0.width.equalTo(self.scrollView).priority(1000)
        }
        
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        let statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        self.mainContentsView.addSubview(self.topGradationView)
        self.topGradationView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(self.mainContentsView)
            $0.height.equalTo(statusBarHeight + (self.navigationHeight))
        }
        
        self.mainContentsView.addSubview(self.topView)
        self.topView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(self.mainContentsView)
            $0.height.equalTo(135)
        }
    }
    
    // MARK: internal function
    

}

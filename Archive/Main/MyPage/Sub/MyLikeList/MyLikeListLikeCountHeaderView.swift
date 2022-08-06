//
//  MyLikeListLikeCountHeaderView.swift
//  Archive
//
//  Created by hanwe on 2022/08/06.
//

import UIKit
import SnapKit
import Then

class MyLikeListLikeCountHeaderView: UICollectionReusableView, ClassIdentifiable {
    
    // MARK: UI property
    
    private let contentsLabel = UILabel().then {
        $0.font = .fonts(.header3)
        $0.textColor = Gen.Colors.gray02.color
        $0.text = "좋아요 한 전시기록"
    }
    
    // MARK: private property
    
    // MARK: internal property
    
    var totalCnt: Int = 0 {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.contentsLabel.attributedText = "좋아요 한 전시기록 \(self?.totalCnt ?? 0)".attrStringCustom(frontText: "좋아요 한 전시기록 ",
                                                                                                          frontFont: .fonts(.subTitle),
                                                                                                          frontTextColor: Gen.Colors.gray02.color,
                                                                                                          rearFont: .fonts(.header3),
                                                                                                          rearTextColor: Gen.Colors.gray01.color)
            }
        }
    }
    
    // MARK: lifeCycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: private function
    
    private func setup() {
        self.addSubview(self.contentsLabel)
        self.contentsLabel.snp.makeConstraints {
            $0.leading.equalTo(self.snp.leading).offset(32)
            $0.trailing.equalTo(self.snp.trailing).offset(-32)
            $0.centerY.equalTo(self.snp.centerY)
        }
    }
    
    // MARK: internal function
    
    
    
}
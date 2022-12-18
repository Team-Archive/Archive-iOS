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
    
    private lazy var contentsLabel = UILabel().then {
        $0.attributedText = "좋아요 한 전시기록  \(self.totalCnt)".attrStringCustom(frontText: "좋아요 한 전시기록 ",
                                                                           frontFont: .fonts(.header3),
                                                                           frontTextColor: Gen.Colors.gray02.color,
                                                                           rearFont: .fonts(.subTitle),
                                                                           rearTextColor: Gen.Colors.gray01.color)
    }
    
    // MARK: private property
    
    // MARK: internal property
    
    var totalCnt: Int = LikeManager.shared.likeList.count {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.contentsLabel.attributedText = "좋아요 한 전시기록  \(self?.totalCnt ?? 0)".attrStringCustom(frontText: "좋아요 한 전시기록 ",
                                                                                                          frontFont: .fonts(.header3),
                                                                                                          frontTextColor: Gen.Colors.gray02.color,
                                                                                                          rearFont: .fonts(.subTitle),
                                                                                                          rearTextColor: Gen.Colors.gray01.color)
            }
        }
    }
    
    // MARK: lifeCycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        NotificationCenter.default.addObserver(self, selector: #selector(self.likeQueryDoneNotificationReceive(notification:)), name: Notification.Name(NotificationDefine.LIKE_QUERY_DONE), object: nil)
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
    
    @objc private func likeQueryDoneNotificationReceive(notification: Notification) {
        self.totalCnt = LikeManager.shared.likeList.count
    }
    
    // MARK: internal function
    
    
    
}

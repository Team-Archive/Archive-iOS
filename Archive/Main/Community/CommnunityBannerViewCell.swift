//
//  CommnunityBannerViewCell.swift
//  Archive
//
//  Created by hanwe on 2022/07/16.
//

import UIKit

class CommnunityBannerViewCell: ArchiveBannerViewCell, ClassIdentifiable {
    // MARK: UI property
    
    let mainContentsView = UIView().then {
        $0.backgroundColor = Gen.Colors.white.color
    }
    
    // MARK: private property
    
    // MARK: internal property
    
//    var infoData: InfoData? {
//        didSet {
//            guard let emotion = self.infoData?.emotion else { return }
//            guard let isSelected = self.infoData?.isSelected else { return }
//            guard let isAllItem = self.infoData?.isAllItem else { return }
//            if isSelected {
//                self.refreshSelectedUI(emotion, isAllSeletedCell: isAllItem)
//            } else {
//                self.refreshUnselectedUI(emotion, isAllSeletedCell: isAllItem)
//            }
//            if isAllItem {
//                self.emotionNameLabel.text = "전체"
//                self.emotionImageView.image = Gen.Images.filterAll.image
//            } else {
//                self.emotionNameLabel.text = emotion.localizationTitle
//                self.emotionImageView.image = emotion.filterImage
//            }
//        }
//    }
    
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
        self.addSubview(self.mainContentsView)
        self.mainContentsView.snp.makeConstraints {
            $0.edges.equalTo(self.snp.edges)
        }
        
    }
}

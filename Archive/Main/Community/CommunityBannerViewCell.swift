//
//  CommunityBannerViewCell.swift
//  Archive
//
//  Created by hanwe on 2022/07/16.
//

import UIKit
import Kingfisher

class CommunityBannerViewCell: ArchiveBannerViewCell, ClassIdentifiable {
    // MARK: UI property
    
    private let mainContentsView = UIView().then {
        $0.backgroundColor = Gen.Colors.white.color
    }
    
    private let summeryImageView = UIImageView().then {
        $0.backgroundColor = .clear
    }
    
    
    // MARK: private property
    
    // MARK: internal property
    
    var infoData: BannerInfo? {
        didSet {
            guard let info = self.infoData else { return }
            DispatchQueue.main.async { [weak self] in
                if let imageUrl = URL(string: info.summaryImageUrl) {
                    self?.summeryImageView.kf.setImage(with: imageUrl)
                }
            }
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
        self.addSubview(self.mainContentsView)
        self.mainContentsView.snp.makeConstraints {
            $0.edges.equalTo(self.snp.edges)
        }
        
        self.mainContentsView.addSubview(self.summeryImageView)
        self.summeryImageView.snp.makeConstraints {
            $0.edges.equalTo(self.mainContentsView.snp.edges)
        }
        
    }
}

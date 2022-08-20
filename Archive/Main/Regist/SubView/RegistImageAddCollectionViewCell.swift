//
//  RegistImageAddCollectionViewCell.swift
//  Archive
//
//  Created by hanwe on 2022/08/20.
//

import UIKit

class RegistImageAddCollectionViewCell: UICollectionViewCell, ClassIdentifiable {
    
    // MARK: UI property
    
    private let mainContentsView = UIView().then {
        $0.backgroundColor = Gen.Colors.gray05.color
    }
    
    private let addImageView = UIImageView().then {
        $0.image = Gen.Images.addPhoto.image
    }
    
    // MARK: private property
    
    // MARK: internal property
    
    var topBarHeight: CGFloat = 0
    
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
            $0.edges.equalTo(self)
        }
        
        self.mainContentsView.addSubview(self.addImageView)
        self.addImageView.snp.makeConstraints {
            $0.center.equalTo(self.mainContentsView).offset(self.topBarHeight)
            $0.width.height.equalTo(48)
        }
    }
    
    // MARK: internal function
    
    // MARK: action
}


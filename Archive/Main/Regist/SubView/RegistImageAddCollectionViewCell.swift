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
        $0.backgroundColor = Gen.Colors.errorRed.color
//        $0.backgroundColor = .blue
    }
    
    // MARK: private property
    
    // MARK: internal property
    
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
    }
    
    // MARK: internal function
    
    // MARK: action
}


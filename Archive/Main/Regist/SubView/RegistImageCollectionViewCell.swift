//
//  RegistImageCollectionViewCell.swift
//  Archive
//
//  Created by hanwe on 2022/08/20.
//

import UIKit
import SnapKit
import Then

class RegistImageCollectionViewCell: UICollectionViewCell, ClassIdentifiable {
    
    // MARK: UI property
    
    private let mainContentsView = UIView().then {
        $0.backgroundColor = Gen.Colors.white.color
    }
    
    private let imageView = UIImageView().then {
        $0.backgroundColor = .clear
    }
    
    // MARK: private property
    
    // MARK: internal property
    
    var image: UIImage? {
        didSet {
            guard let image = image else { return }
            DispatchQueue.main.async { [weak self] in
                self?.imageView.image = image
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
            $0.edges.equalTo(self)
        }
        
        self.mainContentsView.addSubview(self.imageView)
        self.imageView.snp.makeConstraints {
            $0.edges.equalTo(self.mainContentsView)
        }
    }
    
    // MARK: internal function
    
    // MARK: action
}


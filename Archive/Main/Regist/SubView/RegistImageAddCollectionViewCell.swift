//
//  RegistImageAddCollectionViewCell.swift
//  Archive
//
//  Created by hanwe on 2022/08/20.
//

import UIKit
import SnapKit
import Then

protocol RegistImageAddCollectionViewCellDelegate: AnyObject {
    func addPhoto()
}

class RegistImageAddCollectionViewCell: UICollectionViewCell, ClassIdentifiable {
    
    // MARK: UI property
    
    let mainContentsView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private let addImageView = UIImageView().then {
        $0.image = Gen.Images.addPhoto.image
    }
    
    private lazy var addPhotoBtn = UIButton().then {
        $0.backgroundColor = .clear
        $0.addTarget(self, action: #selector(addPhotoAction), for: .touchUpInside)
    }
    
    // MARK: private property
    
    // MARK: internal property
    
    var topBarHeight: CGFloat = 0
    
    weak var delegate: RegistImageAddCollectionViewCellDelegate?
    
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
        
        self.mainContentsView.addSubview(self.addPhotoBtn)
        self.addPhotoBtn.snp.makeConstraints {
            $0.edges.equalTo(self.mainContentsView)
        }
    }
    
    @objc private func addPhotoAction() {
        self.delegate?.addPhoto()
    }
    
    // MARK: internal function
    
    // MARK: action
}


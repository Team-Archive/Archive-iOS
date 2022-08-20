//
//  RegistImageCollectionViewCell.swift
//  Archive
//
//  Created by hanwe on 2022/08/20.
//

import UIKit
import SnapKit
import Then

protocol RegistImageCollectionViewCellDelegate: AnyObject {
    func editPhoto(indexPath: IndexPath?)
}

class RegistImageCollectionViewCell: UICollectionViewCell, ClassIdentifiable {
    
    // MARK: UI property
    
    private let mainContentsView = UIView().then {
        $0.backgroundColor = Gen.Colors.white.color
    }
    
    private let imageView = UIImageView().then {
        $0.backgroundColor = .clear
        $0.contentMode = .scaleAspectFit
    }
    
    private lazy var editBtn = UIButton().then {
        $0.setImageAllState(Gen.Images.iconCrop.image)
        $0.addTarget(self, action: #selector(editPhotoAction), for: .touchUpInside)
    }
    
    // MARK: private property
    
    // MARK: internal property
    
    var imageInfo: RegistImageInfo? {
        didSet {
            guard let imageInfo = imageInfo else { return }
            DispatchQueue.main.async { [weak self] in
                self?.imageView.image = imageInfo.image
                self?.mainContentsView.backgroundColor = imageInfo.color
            }
        }
    }
    
    var indexPath: IndexPath?
    
    weak var delegate: RegistImageCollectionViewCellDelegate?
    
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
        
        self.mainContentsView.addSubview(self.editBtn)
        self.editBtn.snp.makeConstraints {
            $0.width.height.equalTo(44)
            $0.bottom.equalTo(self.mainContentsView).offset(-40)
            $0.trailing.equalTo(self.mainContentsView.snp.trailing).offset(-21)
        }
    }
    
    @objc private func editPhotoAction() {
        self.delegate?.editPhoto(indexPath: self.indexPath)
    }
    
    // MARK: internal function
    
    // MARK: action
}


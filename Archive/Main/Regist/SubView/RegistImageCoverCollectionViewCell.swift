//
//  RegistImageCoverCollectionViewCell.swift
//  Archive
//
//  Created by hanwe on 2022/08/20.
//

import UIKit

class RegistImageCoverCollectionViewCell: UICollectionViewCell, ClassIdentifiable {
    
    // MARK: UI property
    
    private let mainContentsView = UIView().then {
        $0.backgroundColor = Gen.Colors.white.color
    }
    
    private let emotionCoverView = UIImageView().then {
        $0.image = Emotion.pleasant.coverAlphaImage
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
    
    var emotion: Emotion? {
        didSet {
            guard let emotion = emotion else { return }
            DispatchQueue.main.async { [weak self] in
                self?.mainContentsView.backgroundColor = emotion.color
                self?.emotionCoverView.image = emotion.coverAlphaImage
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
            $0.leading.equalTo(self.mainContentsView).offset(32)
            $0.trailing.equalTo(self.mainContentsView).offset(-32)
            $0.height.equalTo(UIScreen.main.bounds.width - 64)
            $0.bottom.equalTo(self.mainContentsView).offset(-75)
        }
        
        self.mainContentsView.addSubview(self.emotionCoverView)
        self.emotionCoverView.snp.makeConstraints {
            $0.leading.equalTo(self.mainContentsView).offset(32)
            $0.trailing.equalTo(self.mainContentsView).offset(-32)
            $0.height.equalTo(UIScreen.main.bounds.width - 64)
            $0.bottom.equalTo(self.mainContentsView).offset(-75)
        }
    }
    
    // MARK: internal function
    
    // MARK: action
}


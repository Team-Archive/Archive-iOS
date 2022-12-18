//
//  CommunityFilterCollectionViewCell.swift
//  Archive
//
//  Created by hanwe on 2022/07/12.
//

import UIKit
import SnapKit
import Kingfisher
import RxSwift
import RxCocoa
import Then

class CommunityFilterCollectionViewCell: UICollectionViewCell, ClassIdentifiable {
    
    // MARK: UI property
    
    private let mainBackgroundView = UIView().then {
        $0.backgroundColor = .red
    }
    
    // MARK: private property
    
    private let disposeBag = DisposeBag()
    
    // MARK: internal property
    
    // MARK: lifeCycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        bind()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
        bind()
    }
    
    // MARK: private function
    
    private func setup() {
        
        self.addSubview(mainBackgroundView)
        self.mainBackgroundView.snp.makeConstraints {
            $0.edges.equalTo(self)
        }
    }
    
    private func bind() {
        
    }
    
    // MARK: internal function
    
}

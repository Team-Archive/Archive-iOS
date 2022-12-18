//
//  CommunityFilterHeaderView.swift
//  Archive
//
//  Created by hanwe on 2022/07/12.
//

import UIKit
import SnapKit
import Then

protocol CommunityFilterHeaderViewDelegate: AnyObject {
    func clickedFilterBtn()
}

class CommunityFilterHeaderView: UICollectionReusableView, ClassIdentifiable {
    
    // MARK: UI property
    
    private lazy var filterBtn = UIButton().then {
        $0.setTitleAllState("필터")
        $0.setTitleColor(Gen.Colors.black.color, for: .normal)
        $0.setTitleColor(Gen.Colors.gray03.color, for: .highlighted)
        $0.titleLabel?.font = .fonts(.button)
        $0.addTarget(self, action: #selector(filterClick), for: .touchUpInside)
    }
    
    private lazy var filterImageBtn = UIButton().then {
        $0.setImageAllState(Gen.Images.filter.image)
        $0.addTarget(self, action: #selector(filterImageClick), for: .touchUpInside)
    }
    
    // MARK: private property
    
    // MARK: internal property
    
    weak var delegate: CommunityFilterHeaderViewDelegate?
    
    // MARK: lifeCycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: private function
    
    private func setup() {
        self.addSubview(self.filterBtn)
        self.filterBtn.snp.makeConstraints {
            $0.trailing.equalTo(self.snp.trailing).offset(-32)
            $0.top.equalTo(self.snp.top).offset(16)
        }
        self.addSubview(self.filterImageBtn)
        self.filterImageBtn.snp.makeConstraints {
            $0.trailing.equalTo(self.filterBtn.snp.leading).offset(0)
            $0.width.equalTo(25)
            $0.height.equalTo(25)
            $0.centerY.equalTo(self.filterBtn.snp.centerY)
        }
    }
    
    @objc private func filterClick() {
        self.delegate?.clickedFilterBtn()
    }
    
    @objc private func filterImageClick() {
        self.delegate?.clickedFilterBtn()
    }
    
    // MARK: internal function
    
    
    
}

//
//  MyLikeEmptyView.swift
//  Archive
//
//  Created by hanwe on 2022/09/03.
//

import UIKit
import SnapKit
import Then

protocol MyLikeEmptyViewDelegate: AnyObject {
    func goToCommunity()
}

class MyLikeEmptyView: UIView {

    // MARK: UIProperty
    
    private let mainContentsView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private let mainImageView = UIImageView().then {
        $0.image = Gen.Images.emptyMyLike.image
    }
    
    private let mainContentsLabel = UILabel().then {
        $0.font = .fonts(.subTitle)
        $0.textColor = Gen.Colors.gray02.color
        $0.text = "좋아요 한 전시기록이 없어요."
        $0.textAlignment = .center
    }
    
    private let subContentsLabel = UILabel().then {
        $0.font = .fonts(.body)
        $0.textColor = Gen.Colors.gray03.color
        $0.text = "전시소통에서 마음에 드는 전시 기록들을\n좋아요로 모아보세요."
        $0.textAlignment = .center
        $0.numberOfLines = 2
    }
    
    private lazy var confirmBtn = ArchiveConfirmButton().then {
        $0.setTitleAllState("전시소통에 좋아요 하러 가기")
        $0.addTarget(self, action: #selector(confirm), for: .touchUpInside)
    }
    
    // MARK: private property
    
    // MARK: internal property
    
    weak var delegate: MyLikeEmptyViewDelegate?
    
    // MARK: lifeCycle
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        
        self.addSubview(self.mainContentsView)
        self.mainContentsView.snp.makeConstraints {
            $0.edges.equalTo(self)
        }
        
        self.mainContentsView.addSubview(self.mainImageView)
        self.mainImageView.snp.makeConstraints {
            $0.top.equalTo(self.mainContentsView).offset(30)
            $0.centerX.equalTo(self.mainContentsView)
            $0.width.equalTo(215)
            $0.height.equalTo(220)
        }
        
        self.mainContentsView.addSubview(self.mainContentsLabel)
        self.mainContentsLabel.snp.makeConstraints {
            $0.top.equalTo(self.mainImageView.snp.bottom).offset(20)
            $0.left.trailing.equalTo(self.mainContentsView)
        }
        
        self.mainContentsView.addSubview(self.subContentsLabel)
        self.subContentsLabel.snp.makeConstraints {
            $0.top.equalTo(self.mainContentsLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalTo(self.mainContentsView)
        }
        
        self.mainContentsView.addSubview(self.confirmBtn)
        self.confirmBtn.snp.makeConstraints {
            $0.top.equalTo(self.subContentsLabel.snp.bottom).offset(32)
            $0.leading.equalTo(self.mainContentsView).offset(32)
            $0.trailing.equalTo(self.mainContentsView).offset(-32)
            $0.height.equalTo(52)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: private function
    
    @objc private func confirm() {
        self.delegate?.goToCommunity()
    }
    
    // MARK: internal function

}

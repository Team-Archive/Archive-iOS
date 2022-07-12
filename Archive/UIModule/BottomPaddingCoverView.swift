//
//  BottomPaddingCoverView.swift
//  Archive
//
//  Created by hanwe on 2022/06/27.
//

import UIKit
import SnapKit
import Then

class BottomPaddingCoverView: UIView { // 노치가 있는 폰에서 하단을 막아버리는 뷰가 디폴트로 들어가있다. 바닥에 깔려야하는 뷰를 만들어야할 때 상속받아보자.
    
    // MARK: private UI property
    
    private lazy var bottomCoverView = UIView().then {
        $0.backgroundColor = self.backgroundColor
    }
    
    // MARK: internal UI property
    
    // MARK: private property
    
    private let paddding = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.safeAreaInsets.bottom ?? 0
    
    // MARK: property
    
    // MARK: lifeCycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: private func
    
    // MARK: func
    
    func makeBottomCoverView() {
        self.addSubview(self.bottomCoverView)
        self.bottomCoverView.snp.makeConstraints {
            $0.leading.equalTo(self.snp.leading)
            $0.trailing.equalTo(self.snp.trailing)
            $0.bottom.equalTo(self.snp.bottom).offset(paddding)
            $0.height.equalTo(self.paddding)
        }
    }
    
}

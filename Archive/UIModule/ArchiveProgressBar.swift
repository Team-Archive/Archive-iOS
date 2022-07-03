//
//  ArchiveProgressBar.swift
//  Archive
//
//  Created by hanwe on 2022/07/03.
//

import UIKit
import SnapKit
import Then

class ArchiveProgressBar: UIView {
    
    // MARK: UI property
    
    private let containerView = UIView().then {
        $0.backgroundColor = Gen.Colors.gray03.color
    }
    
    private let progressView = UIView().then {
        $0.backgroundColor = Gen.Colors.white.color
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
        self.addSubview(self.containerView)
        self.containerView.snp.makeConstraints {
            $0.edges.equalTo(self)
        }
        
        self.addSubview(self.progressView)
        self.progressView.snp.makeConstraints {
            $0.leading.top.bottom.equalTo(self.containerView)
            $0.width.equalTo(0)
        }
    }
    
    // MARK: function
    
    func setPercent(_ percent: CGFloat) {
        print("percent: \(percent)")
        DispatchQueue.main.async { [weak self] in
            self?.progressView.snp.updateConstraints {
                $0.width.equalTo(UIScreen.main.bounds.width * percent)
            }
        }
    }

}

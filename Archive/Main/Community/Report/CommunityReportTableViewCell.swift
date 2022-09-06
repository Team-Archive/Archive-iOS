//
//  CommunityReportTableViewCell.swift
//  Archive
//
//  Created by hanwe on 2022/09/06.
//

import UIKit
import SnapKit
import Then

class CommunityReportTableViewCell: UITableViewCell, ClassIdentifiable {
    
    // MARK: UIProperty
    
    private let contentsLabel = UILabel().then {
        $0.font = .fonts(.body)
        $0.textColor = Gen.Colors.gray01.color
    }
    
    private let underlineView = UIView().then {
        $0.backgroundColor = Gen.Colors.gray05.color
    }
    
    // MARK: private property
    
    // MARK: internal property
    
    var infoData: String? {
        didSet {
            guard let info = self.infoData else { return }
            DispatchQueue.main.async { [weak self] in
                self?.contentsLabel.text = info
            }
        }
    }
    
    // MARK: lifeCycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: private function
    
    private func setup() {
        
        self.addSubview(self.underlineView)
        self.underlineView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalTo(self)
            $0.height.equalTo(1)
        }
        
        self.addSubview(self.contentsLabel)
        self.contentsLabel.snp.makeConstraints {
            $0.top.equalTo(self)
            $0.bottom.equalTo(self.underlineView.snp.top)
            $0.leading.equalTo(self).offset(32)
            $0.trailing.equalTo(self).offset(-32)
        }
    }
    
    // MARK: internal function
    
}

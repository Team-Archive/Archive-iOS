//
//  TimeFilterRadioButton.swift
//  Archive
//
//  Created by hanwe on 2022/06/22.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then

protocol TimeFilterRadioButtonDelegate: AnyObject {
    func selectedSortBy(view: TimeFilterRadioButton, type: ArchiveSortType)
}

@objc enum ArchiveSortType: Int, CaseIterable {
    case sortByRegist = 0
    case sortByVisit
    
    static func getArchiveSortTypeFromRawValue(_ rawValue: Int) -> ArchiveSortType? {
        if rawValue + 1 > ArchiveSortType.allCases.count { return nil }
        var currentIndex: Int = 0
        for item in ArchiveSortType.allCases {
            if currentIndex == rawValue {
                return item
            }
            currentIndex += 1
        }
        return nil
    }
    
    var toAPIRawValue: String {
        switch self {
        case .sortByRegist:
            return "createdAt"
        case .sortByVisit:
            return "watchedOn"
        }
    }
}

class TimeFilterRadioButton: UIView {
    
    // MARK: UI property
    
    private let mainContentsView = UIView().then {
        $0.backgroundColor = Gen.Colors.white.color
    }
    
    private let leftContentsView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private lazy var sortByRegistImageBtn = UIButton().then {
        $0.setImage(Gen.Images.radioSelected.image, for: .normal)
        $0.addTarget(self, action: #selector(selectedSortByRegist), for: .touchUpInside)
    }
    
    private lazy var sortByRegistTextBtn = UIButton().then {
        $0.setTitleAllState("최신 기록순")
        $0.titleLabel?.font = .fonts(.body)
        $0.setTitleColor(Gen.Colors.black.color, for: .normal)
        $0.setTitleColor(Gen.Colors.black.color, for: .focused)
        $0.setTitleColor(Gen.Colors.black.color, for: .selected)
        $0.setTitleColor(Gen.Colors.gray03.color, for: .highlighted)
        $0.addTarget(self, action: #selector(selectedSortByRegist), for: .touchUpInside)
    }
    
    private let rightContentsView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private lazy var sortByVisitImageBtn = UIButton().then {
        $0.setImage(Gen.Images.radioUnSelected.image, for: .normal)
        $0.addTarget(self, action: #selector(selectedSortByVisit), for: .touchUpInside)
    }
    
    private lazy var sortByVisitTextBtn = UIButton().then {
        $0.setTitleAllState("전시 관람순")
        $0.titleLabel?.font = .fonts(.body)
        $0.setTitleColor(Gen.Colors.black.color, for: .normal)
        $0.setTitleColor(Gen.Colors.black.color, for: .focused)
        $0.setTitleColor(Gen.Colors.black.color, for: .selected)
        $0.setTitleColor(Gen.Colors.gray03.color, for: .highlighted)
        $0.addTarget(self, action: #selector(selectedSortByVisit), for: .touchUpInside)
    }
    
    // MARK: private property
    
    // MARK: internal property
    
    weak var delegate: TimeFilterRadioButtonDelegate?
    
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
            $0.edges.equalTo(self.snp.edges)
        }
        
        self.mainContentsView.addSubview(self.leftContentsView)
        self.leftContentsView.snp.makeConstraints {
            $0.leading.equalTo(self.mainContentsView.snp.leading)
            $0.top.equalTo(self.mainContentsView.snp.top)
            $0.bottom.equalTo(self.mainContentsView.snp.bottom)
        }
        
        self.mainContentsView.addSubview(self.rightContentsView)
        self.rightContentsView.snp.makeConstraints {
            $0.trailing.equalTo(self.mainContentsView.snp.trailing)
            $0.top.equalTo(self.mainContentsView.snp.top)
            $0.bottom.equalTo(self.mainContentsView.snp.bottom)
            $0.leading.equalTo(self.leftContentsView.snp.trailing)
            $0.width.equalTo(self.leftContentsView.snp.width)
        }
        
        self.leftContentsView.addSubview(self.sortByRegistImageBtn)
        self.sortByRegistImageBtn.snp.makeConstraints {
            $0.leading.equalTo(self.leftContentsView.snp.leading)
            $0.centerY.equalTo(self.leftContentsView.snp.centerY)
            $0.width.equalTo(24)
            $0.height.equalTo(24)
        }
        
        self.leftContentsView.addSubview(self.sortByRegistTextBtn)
        self.sortByRegistTextBtn.snp.makeConstraints {
            $0.leading.equalTo(self.sortByRegistImageBtn.snp.trailing).offset(8)
            $0.centerY.equalTo(self.sortByRegistImageBtn.snp.centerY)
        }
        
        self.rightContentsView.addSubview(self.sortByVisitImageBtn)
        self.sortByVisitImageBtn.snp.makeConstraints {
            $0.leading.equalTo(self.rightContentsView.snp.leading)
            $0.centerY.equalTo(self.rightContentsView.snp.centerY)
            $0.width.equalTo(24)
            $0.height.equalTo(24)
        }
        
        self.rightContentsView.addSubview(self.sortByVisitTextBtn)
        self.sortByVisitTextBtn.snp.makeConstraints {
            $0.leading.equalTo(self.sortByVisitImageBtn.snp.trailing).offset(8)
            $0.centerY.equalTo(self.sortByVisitImageBtn.snp.centerY)
        }
        
    }
    
    @objc private func selectedSortByRegist() {
        self.sortByVisitImageBtn.setImageAllState(Gen.Images.radioUnSelected.image)
        self.sortByRegistImageBtn.setImageAllState(Gen.Images.radioSelected.image)
        self.delegate?.selectedSortBy(view: self, type: .sortByRegist)
    }
    
    @objc private func selectedSortByVisit() {
        self.sortByVisitImageBtn.setImageAllState(Gen.Images.radioSelected.image)
        self.sortByRegistImageBtn.setImageAllState(Gen.Images.radioUnSelected.image)
        self.delegate?.selectedSortBy(view: self, type: .sortByVisit)
    }
    
    // MARK: function
    
    func setSelectedRadioButton(_ selectedType: ArchiveSortType) {
        switch selectedType {
        case .sortByRegist:
            self.sortByVisitImageBtn.setImageAllState(Gen.Images.radioUnSelected.image)
            self.sortByRegistImageBtn.setImageAllState(Gen.Images.radioSelected.image)
        case .sortByVisit:
            self.sortByVisitImageBtn.setImageAllState(Gen.Images.radioSelected.image)
            self.sortByRegistImageBtn.setImageAllState(Gen.Images.radioUnSelected.image)
        }
    }
    
}

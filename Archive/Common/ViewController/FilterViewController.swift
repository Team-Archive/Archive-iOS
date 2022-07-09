//
//  FilterViewController.swift
//  Archive
//
//  Created by hanwe on 2022/07/09.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift
import Then

class FilterViewController: UIViewController {
    
    enum showAnimationType {
        case fadeIn
        case present
    }
    
    // MARK: UI property
    
    private let mainBackgroundView = UIView().then {
        $0.backgroundColor = Gen.Colors.dim.color
    }
    
    private let mainContentsView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private let bottomView = BottomPaddingCoverView().then {
        $0.backgroundColor = Gen.Colors.white.color
    }
    
    private let sortByTimeTitleLabel = UILabel().then {
        $0.font = .fonts(.header3)
        $0.textColor = Gen.Colors.black.color
        $0.text = "시간 순으로 보기"
    }
    
    private let acceptBtn = UIButton().then {
        $0.setTitleAllState("적용")
        $0.setTitleColor(Gen.Colors.black.color, for: .normal)
        $0.setTitleColor(Gen.Colors.pressedBtn.color, for: .highlighted)
    }
    
    private let radioView = TimeFilterRadioButton().then {
        $0.backgroundColor = .clear
    }
    
    private let sortByEmotionTitleLabel = UILabel().then {
        $0.font = .fonts(.header3)
        $0.textColor = Gen.Colors.black.color
        $0.text = "감정 별로 보기"
    }
    
    private let emotionSelectView = ArchiveSelectEmotionView().then {
        $0.backgroundColor = .clear
    }
    
    // MARK: private property
    
    // MARK: internal property
    
    var showAnimationType: showAnimationType = .present
    var isWillDismissWhenDimTap: Bool = true
    
    // MARK: lifeCycle
    
    deinit {
        print("\(self) deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.modalPresentationStyle = .overFullScreen
        let dimTap = UITapGestureRecognizer(target: self, action: #selector(self.dismissAction(_:)))
        self.mainContentsView.isUserInteractionEnabled = true
        self.mainContentsView.addGestureRecognizer(dimTap)
    }
    
    override func loadView() {
        super.loadView()
        self.view.addSubview(self.mainBackgroundView)
        self.mainBackgroundView.snp.makeConstraints {
            $0.edges.equalTo(self.view)
        }
        
        self.view.addSubview(self.mainContentsView)
        let safeGuide = self.view.safeAreaLayoutGuide
        self.mainContentsView.snp.makeConstraints {
            $0.edges.equalTo(safeGuide)
        }
        
        self.mainContentsView.addSubview(self.bottomView)
        switch self.showAnimationType {
        case .present:
            self.bottomView.snp.makeConstraints {
                $0.leading.equalTo(self.mainContentsView.snp.leading)
                $0.trailing.equalTo(self.mainContentsView.snp.trailing)
                $0.bottom.equalTo(self.mainContentsView.snp.bottom).offset(150)
                $0.height.equalTo(200)
            }
        case .fadeIn:
            self.bottomView.snp.makeConstraints {
                $0.leading.equalTo(mainContentsView.snp.leading)
                $0.trailing.equalTo(mainContentsView.snp.trailing)
                $0.bottom.equalTo(mainContentsView.snp.bottom)
            }
        }
        bottomView.clipsToBounds = false
        bottomView.layer.cornerRadius = 20
        bottomView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner] // Top right corner, Top left corner respectively
        self.bottomView.makeBottomCoverView()
        
        self.bottomView.addSubview(self.sortByTimeTitleLabel)
        self.sortByTimeTitleLabel.snp.makeConstraints {
            $0.top.equalTo(self.bottomView.snp.top).offset(28)
            $0.leading.equalTo(self.bottomView.snp.leading).offset(32)
        }
    }
    
    // MARK: private function
    
    @objc private func dismissAction(_ recognizer: UITapGestureRecognizer) {
        if self.isWillDismissWhenDimTap {
            self.close()
        }
    }
    
    private func close() {
        self.view.fadeOut(completeHandler: {
            self.dismiss(animated: false)
        })
    }
    
    private func moveAnimation() {
        self.view.layoutIfNeeded()
        self.bottomView.snp.updateConstraints {
            $0.leading.equalTo(self.mainContentsView.snp.leading)
            $0.trailing.equalTo(self.mainContentsView.snp.trailing)
            $0.bottom.equalTo(self.mainContentsView.snp.bottom)
        }
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: internal function
    
    func showEffect() {
        self.mainBackgroundView.fadeIn(completeHandler: nil)
        switch self.showAnimationType {
        case .fadeIn:
            self.mainContentsView.fadeIn(completeHandler: nil)
        case .present:
            self.moveAnimation()
        }
    }
    

    
}

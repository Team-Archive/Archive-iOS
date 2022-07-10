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
    
    private lazy var dismissAreaView = UIView().then {
        $0.backgroundColor = .clear
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissAction(_:)))
        $0.isUserInteractionEnabled = true
        $0.addGestureRecognizer(tap)
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
    
    private lazy var acceptBtn = UIButton().then {
        $0.setTitleAllState("적용")
        $0.setTitleColor(Gen.Colors.black.color, for: .normal)
        $0.setTitleColor(Gen.Colors.pressedBtn.color, for: .highlighted)
        $0.titleLabel?.font = .fonts(.button)
        $0.addTarget(self, action: #selector(confirm), for: .touchUpInside)
    }
    
    private let radioView = TimeFilterRadioButton().then {
        $0.backgroundColor = .clear
    }
    
    private let sortByEmotionTitleLabel = UILabel().then {
        $0.font = .fonts(.header3)
        $0.textColor = Gen.Colors.black.color
        $0.text = "감정 별로 보기"
    }
    
    private let emotionSelectView = ArchiveFilterEmotionView().then {
        $0.backgroundColor = .clear
    }
    
    // MARK: private property
    
    private let disposeBag = DisposeBag()
    private var timeSortBy: TimeFilterRadioButton.sortType
    private var emotionSortBy: Emotion?
    
    
    // MARK: internal property
    
    var showAnimationType: showAnimationType = .present
    var isWillDismissWhenDimTap: Bool = true
    
    // MARK: lifeCycle
    
    init(timeSortBy: TimeFilterRadioButton.sortType, emotionSortBy: Emotion?) {
        self.timeSortBy = timeSortBy
        self.emotionSortBy = emotionSortBy
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("\(self) deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
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
                $0.height.equalTo(260)
            }
        case .fadeIn:
            self.bottomView.snp.makeConstraints {
                $0.leading.equalTo(mainContentsView.snp.leading)
                $0.trailing.equalTo(mainContentsView.snp.trailing)
                $0.bottom.equalTo(mainContentsView.snp.bottom)
            }
        }
        self.bottomView.clipsToBounds = false
        self.bottomView.layer.cornerRadius = 20
        self.bottomView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        self.bottomView.makeBottomCoverView()
        
        self.mainContentsView.addSubview(self.dismissAreaView)
        self.dismissAreaView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(self.mainContentsView)
            $0.bottom.equalTo(self.bottomView.snp.top)
        }
        
        self.bottomView.addSubview(self.sortByTimeTitleLabel)
        self.sortByTimeTitleLabel.snp.makeConstraints {
            $0.top.equalTo(self.bottomView.snp.top).offset(28)
            $0.leading.equalTo(self.bottomView.snp.leading).offset(32)
        }
        
        self.bottomView.addSubview(self.acceptBtn)
        self.acceptBtn.snp.makeConstraints {
            $0.trailing.equalTo(self.bottomView.snp.trailing).offset(-32)
            $0.centerY.equalTo(self.sortByTimeTitleLabel)
        }
        
        self.bottomView.addSubview(self.radioView)
        self.radioView.snp.makeConstraints {
            $0.top.equalTo(self.sortByTimeTitleLabel.snp.bottom).offset(26)
            $0.leading.equalTo(self.bottomView.snp.leading).offset(32)
            $0.trailing.equalTo(self.bottomView.snp.trailing).offset(32)
            $0.height.equalTo(24)
        }
        self.radioView.delegate = self
        
        self.bottomView.addSubview(self.sortByEmotionTitleLabel)
        self.sortByEmotionTitleLabel.snp.makeConstraints {
            $0.top.equalTo(self.radioView.snp.bottom).offset(32)
            $0.leading.trailing.equalTo(self.bottomView).offset(32)
        }
        
        
        self.bottomView.addSubview(self.emotionSelectView)
        self.emotionSelectView.snp.makeConstraints {
            $0.top.equalTo(self.sortByEmotionTitleLabel.snp.bottom).offset(26)
            $0.leading.trailing.equalTo(self.bottomView)
            $0.height.equalTo(77)
        }
        self.emotionSelectView.delegate = self
    }
    
    private func bind() {
        
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
    
    @objc private func confirm() {
        print("얍")
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


extension FilterViewController: TimeFilterRadioButtonDelegate, ArchiveFilterEmotionViewDelegate {
    
    func selectedSortBy(view: TimeFilterRadioButton, type: TimeFilterRadioButton.sortType) {
        self.timeSortBy = type
    }
    
    
    func didSelectedItem(view: ArchiveSelectEmotionView, didSelectedAt index: Int) {
        
    }
    
}

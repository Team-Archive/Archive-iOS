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

@objc protocol FilterViewControllerDelegate: AnyObject {
    @objc optional func filterAccepted(view: FilterViewController, sortBy: ArchiveSortType, emotion: Emotion, isAllEmotionSelected: Bool)
}

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
    private var timeSortBy: ArchiveSortType
    private var emotionSortBy: Emotion?
    
    
    // MARK: internal property
    
    var showAnimationType: showAnimationType = .present
    var isWillDismissWhenDimTap: Bool = true
    
    weak var delegate: FilterViewControllerDelegate?
    
    // MARK: lifeCycle
    
    init(timeSortBy: ArchiveSortType, emotionSortBy: Emotion?) {
        self.timeSortBy = timeSortBy
        self.emotionSortBy = emotionSortBy
        super.init(nibName: nil, bundle: nil)
        self.radioView.setSelectedRadioButton(timeSortBy)
        self.emotionSelectView.setSelecteEmotion(emotionSortBy)
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
            switch self.showAnimationType {
            case .present:
                self.bottomView.snp.updateConstraints {
                    $0.leading.equalTo(self.mainContentsView.snp.leading)
                    $0.trailing.equalTo(self.mainContentsView.snp.trailing)
                    $0.bottom.equalTo(self.mainContentsView.snp.bottom).offset(150)
                }
            case .fadeIn:
                break
            }
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
        if let selectedEmotion = self.emotionSortBy {
            self.delegate?.filterAccepted?(view: self,
                                           sortBy: self.timeSortBy,
                                           emotion: selectedEmotion,
                                           isAllEmotionSelected: false)
        } else {
            self.delegate?.filterAccepted?(view: self,
                                           sortBy: self.timeSortBy,
                                           emotion: .fun,
                                           isAllEmotionSelected: true)
        }
        close()
    }
    
    // MARK: internal function
    
    func showEffect() {
        self.view.alpha = 1
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
    
    func selectedSortBy(view: TimeFilterRadioButton, type: ArchiveSortType) {
        self.timeSortBy = type
    }
    
    func didSelectedItem(view: ArchiveFilterEmotionView, didSelectedAt emotion: Emotion, isSelectedAll: Bool) {
        if isSelectedAll {
            self.emotionSortBy = nil
        } else {
            self.emotionSortBy = emotion
        }
    }
    
}

class FilterViewControllerDelegateProxy: DelegateProxy<FilterViewController, FilterViewControllerDelegate>, DelegateProxyType, FilterViewControllerDelegate {

    static func currentDelegate(for object: FilterViewController) -> FilterViewControllerDelegate? {
        return object.delegate
    }

    static func setCurrentDelegate(_ delegate: FilterViewControllerDelegate?, to object: FilterViewController) {
        object.delegate = delegate
    }

    static func registerKnownImplementations() {
        self.register { (view) -> FilterViewControllerDelegateProxy in
            FilterViewControllerDelegateProxy(parentObject: view, delegateProxy: self)
        }
    }
}

extension Reactive where Base: FilterViewController {
    var delegate: DelegateProxy<FilterViewController, FilterViewControllerDelegate> {
        return FilterViewControllerDelegateProxy.proxy(for: self.base)
    }

    var selected: Observable<(ArchiveSortType, Emotion, Bool)> {
        return delegate.methodInvoked(#selector(FilterViewControllerDelegate.filterAccepted(view:sortBy:emotion:isAllEmotionSelected:)))
            .map { result in
                let sortByRawValue = (result[1] as? Int) ?? 0
                let sortBy = ArchiveSortType.getArchiveSortTypeFromRawValue(sortByRawValue) ?? .sortByRegist
                let emotionRawValue = (result[2] as? Int) ?? 0
                let emotion = Emotion.getEmotionFromIndex(emotionRawValue) ?? .fun
                let isAllEmotionSelected = (result[3] as? Bool) ?? true
                return (sortBy, emotion, isAllEmotionSelected)
            }
    }
}

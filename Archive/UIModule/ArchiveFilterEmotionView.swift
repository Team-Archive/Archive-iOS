//
//  ArchiveFilterEmotionView.swift
//  Archive
//
//  Created by hanwe on 2022/07/09.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then

@objc protocol ArchiveFilterEmotionViewDelegate: AnyObject {
    @objc optional func didSelectedItem(view: ArchiveFilterEmotionView, didSelectedAt emotion: Emotion, isSelectedAll: Bool)
}

class ArchiveFilterEmotionView: UIView {
    
    // MARK: UI property
    
    private let mainContentsView = UIView().then {
        $0.backgroundColor = Gen.Colors.white.color
    }
    
    private let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: UICollectionViewLayout()).then {
        $0.backgroundColor = Gen.Colors.white.color
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 52, height: 70)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 32, bottom: 0, right: 32)
        $0.collectionViewLayout = layout
    }
    
    // MARK: private property
    
    private var feedbackGenerator: UISelectionFeedbackGenerator?
    
    private var currentSelectedIndex: Int = 0 {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.collectionView.reloadData()
            }
        }
    }
    
    // MARK: internal property
    
    weak var delegate: ArchiveFilterEmotionViewDelegate?
    
    var layout: UICollectionViewLayout? {
        didSet {
            guard let layout = layout else { return }
            self.collectionView.collectionViewLayout = layout
        }
    }
    
    // MARK: lifeCycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        setGenerator()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
        setGenerator()
    }
    
    // MARK: private function
    
    private func setup() {
        self.addSubview(self.mainContentsView)
        self.mainContentsView.snp.makeConstraints {
            $0.edges.equalTo(self.snp.edges)
        }
        self.mainContentsView.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints {
            $0.edges.equalTo(self.mainContentsView.snp.edges)
        }
        
        self.collectionView.register(EmotionFilterCollectionViewCell.self, forCellWithReuseIdentifier: EmotionFilterCollectionViewCell.identifier)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    private func setGenerator() {
        self.feedbackGenerator = UISelectionFeedbackGenerator()
        self.feedbackGenerator?.prepare()
    }
    
    // MARK: function
    
    func setSelecteEmotion(_ emotion: Emotion) {
        self.currentSelectedIndex = emotion.toOrderIndex
        self.collectionView.reloadData()
    }
    
}

extension ArchiveFilterEmotionView: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Emotion.allCases.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmotionFilterCollectionViewCell.identifier, for: indexPath) as? EmotionFilterCollectionViewCell else { return UICollectionViewCell() }
        let isSelected = self.currentSelectedIndex == indexPath.item ? true : false
        if indexPath.item == 0 {
            cell.infoData = EmotionFilterCollectionViewCell.InfoData(emotion: .fun,
                                                                     isSelected: isSelected,
                                                                     isAllItem: true)
        } else {
            cell.infoData = EmotionFilterCollectionViewCell.InfoData(emotion: Emotion.allCases[indexPath.item - 1],
                                                                     isSelected: isSelected,
                                                                     isAllItem: false)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.currentSelectedIndex = indexPath.item
        self.feedbackGenerator?.selectionChanged()
        guard let emotion = Emotion.getEmotionFromIndex(indexPath.item) else { return }
        self.delegate?.didSelectedItem?(view: self, didSelectedAt: emotion, isSelectedAll: false)
    }
    
}

class ArchiveFilterEmotionViewDelegateProxy: DelegateProxy<ArchiveFilterEmotionView, ArchiveFilterEmotionViewDelegate>, DelegateProxyType, ArchiveFilterEmotionViewDelegate {
    
    static func currentDelegate(for object: ArchiveFilterEmotionView) -> ArchiveFilterEmotionViewDelegate? {
        return object.delegate
    }
    
    static func setCurrentDelegate(_ delegate: ArchiveFilterEmotionViewDelegate?, to object: ArchiveFilterEmotionView) {
        object.delegate = delegate
    }
    
    static func registerKnownImplementations() {
        self.register { (view) -> ArchiveFilterEmotionViewDelegateProxy in
            ArchiveFilterEmotionViewDelegateProxy(parentObject: view, delegateProxy: self)
        }
    }
}

extension Reactive where Base: ArchiveFilterEmotionView {
    var delegate: DelegateProxy<ArchiveFilterEmotionView, ArchiveFilterEmotionViewDelegate> {
        return ArchiveFilterEmotionViewDelegateProxy.proxy(for: self.base)
    }

    var selectedEmotion: Observable<(Emotion, Bool)> {
        return delegate.methodInvoked(#selector(ArchiveFilterEmotionViewDelegate.didSelectedItem(view:didSelectedAt:isSelectedAll:)))
            .map { result in
                let rawValue = result[1] as? Int ?? 0
                let isSelectedAll = result[2] as? Bool ?? false
                return ((Emotion.init(rawValue: rawValue) ?? .fun), isSelectedAll)
            }
    }
}


class EmotionFilterCollectionViewCell: UICollectionViewCell, ClassIdentifiable {
    
    struct InfoData {
        let emotion: Emotion?
        let isSelected: Bool
        let isAllItem: Bool
    }
    
    // MARK: UI property
    
    let mainContentsView = UIView().then {
        $0.backgroundColor = Gen.Colors.white.color
    }
    
    let emotionImageContainerView = UIView().then {
        $0.backgroundColor = .clear
        $0.layer.cornerRadius = 26
        $0.layer.borderWidth = 1
    }
    
    let emotionImageView = UIImageView().then {
        $0.backgroundColor = .clear
    }
    
    let emotionNameLabel = UILabel().then {
        $0.font = .fonts(.body)
        $0.textAlignment = .center
    }
    
    // MARK: private property
    
    // MARK: internal property
    
    var infoData: InfoData? {
        didSet {
            guard let emotion = self.infoData?.emotion else { return }
            guard let isSelected = self.infoData?.isSelected else { return }
            guard let isAllItem = self.infoData?.isAllItem else { return }
            if isSelected {
                self.refreshSelectedUI(emotion, isAllSeletedCell: isAllItem)
            } else {
                self.refreshUnselectedUI(emotion, isAllSeletedCell: isAllItem)
            }
            if isAllItem {
                self.emotionNameLabel.text = "전체"
                self.emotionImageView.image = Gen.Images.filterAll.image
            } else {
                self.emotionNameLabel.text = emotion.localizationTitle
                self.emotionImageView.image = emotion.filterImage
            }
        }
    }
    
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
        
        self.mainContentsView.addSubview(self.emotionImageContainerView)
        self.emotionImageContainerView.snp.makeConstraints {
            $0.top.equalTo(self.mainContentsView.snp.top)
            $0.centerX.equalTo(self.mainContentsView.snp.centerX)
            $0.width.equalTo(52)
            $0.height.equalTo(52)
        }
        
        self.emotionImageContainerView.addSubview(self.emotionImageView)
        self.emotionImageView.snp.makeConstraints {
            $0.center.equalTo(self.emotionImageContainerView.snp.center)
            $0.width.height.equalTo(42)
        }
        
        self.mainContentsView.addSubview(self.emotionNameLabel)
        self.emotionNameLabel.snp.makeConstraints {
            $0.top.equalTo(self.emotionImageView.snp.bottom).offset(4)
            $0.leading.equalTo(self.mainContentsView.snp.leading)
            $0.trailing.equalTo(self.mainContentsView.snp.trailing)
        }
    }
    
    private func refreshSelectedUI(_ emotion: Emotion, isAllSeletedCell: Bool) {
        if isAllSeletedCell {
            self.emotionImageContainerView.layer.borderColor = Gen.Colors.black.color.cgColor
        } else {
            self.emotionImageContainerView.layer.borderColor = emotion.color.cgColor
        }
        self.emotionNameLabel.textColor = Gen.Colors.black.color
    }
    
    private func refreshUnselectedUI(_ emotion: Emotion, isAllSeletedCell: Bool) {
        self.emotionImageContainerView.layer.borderColor = UIColor.clear.cgColor
        self.emotionNameLabel.textColor = Gen.Colors.gray03.color
    }
    
    // MARK: internal function
    
    // MARK: action
}

//
//  ArchiveSelectEmotionView.swift
//  Archive
//
//  Created by hanwe on 2022/06/05.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then

@objc protocol ArchiveSelectEmotionViewDelegate: AnyObject {
    @objc optional func didSelectedItem(view: ArchiveSelectEmotionView, didSelectedAt emotion: Emotion)
}

class ArchiveSelectEmotionView: UIView {
    
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
        layout.itemSize = CGSize(width: 50, height: 70)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 32, bottom: 0, right: 32)
        $0.collectionViewLayout = layout
    }
    
    // MARK: private property
    
    private var feedbackGenerator: UIImpactFeedbackGenerator?
    
    private var currentSelectedIndex: Int = 0 {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.collectionView.reloadData()
            }
        }
    }
    
    // MARK: internal property
    
    weak var delegate: ArchiveSelectEmotionViewDelegate?
    
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
        
        self.collectionView.register(EmotionSelectCollectionViewCell.self, forCellWithReuseIdentifier: EmotionSelectCollectionViewCell.identifier)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    private func setGenerator() {
        self.feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        self.feedbackGenerator?.prepare()
    }
    
    // MARK: function
    
    func setSelecteEmotion(_ emotion: Emotion) {
        self.currentSelectedIndex = emotion.toOrderIndex
        self.collectionView.reloadData()
    }
    
}

extension ArchiveSelectEmotionView: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Emotion.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmotionSelectCollectionViewCell.identifier, for: indexPath) as? EmotionSelectCollectionViewCell else { return UICollectionViewCell() }
        let isSelected = self.currentSelectedIndex == indexPath.item ? true : false
        cell.infoData = (Emotion.allCases[indexPath.item], isSelected)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.currentSelectedIndex = indexPath.item
        self.feedbackGenerator?.impactOccurred()
        guard let emotion = Emotion.getEmotionFromIndex(indexPath.item) else { return }
        self.delegate?.didSelectedItem?(view: self, didSelectedAt: emotion)
    }
    
}

class ArchiveSelectEmotionViewDelegateProxy: DelegateProxy<ArchiveSelectEmotionView, ArchiveSelectEmotionViewDelegate>, DelegateProxyType, ArchiveSelectEmotionViewDelegate {
    
    static func currentDelegate(for object: ArchiveSelectEmotionView) -> ArchiveSelectEmotionViewDelegate? {
        return object.delegate
    }
    
    static func setCurrentDelegate(_ delegate: ArchiveSelectEmotionViewDelegate?, to object: ArchiveSelectEmotionView) {
        object.delegate = delegate
    }
    
    static func registerKnownImplementations() {
        self.register { (view) -> ArchiveSelectEmotionViewDelegateProxy in
            ArchiveSelectEmotionViewDelegateProxy(parentObject: view, delegateProxy: self)
        }
    }
}

extension Reactive where Base: ArchiveSelectEmotionView {
    var delegate: DelegateProxy<ArchiveSelectEmotionView, ArchiveSelectEmotionViewDelegate> {
        return ArchiveSelectEmotionViewDelegateProxy.proxy(for: self.base)
    }

    var selectedEmotion: Observable<Emotion> {
        return delegate.methodInvoked(#selector(ArchiveSelectEmotionViewDelegate.didSelectedItem(view:didSelectedAt:)))
            .map { result in
                let rawValue = result[1] as? Int ?? 0
                return Emotion.init(rawValue: rawValue) ?? .fun
            }
    }
}


class EmotionSelectCollectionViewCell: UICollectionViewCell, ClassIdentifiable {
    
    // MARK: UI property
    
    let mainContentsView = UIView().then {
        $0.backgroundColor = Gen.Colors.white.color
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
    
    var infoData: (emotion: Emotion?, isSelected: Bool)? {
        didSet {
            guard let emotion = self.infoData?.emotion else { return }
            guard let isSelected = self.infoData?.isSelected else { return }
            self.emotionNameLabel.text = emotion.localizationTitle
            if isSelected {
                self.refreshSelectedUI(emotion)
            } else {
                self.refreshUnselectedUI(emotion)
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
        
        self.mainContentsView.addSubview(self.emotionImageView)
        self.emotionImageView.snp.makeConstraints {
            $0.top.equalTo(self.mainContentsView.snp.top)
            $0.centerX.equalTo(self.mainContentsView.snp.centerX)
            $0.width.equalTo(48)
            $0.height.equalTo(48)
        }
        
        self.mainContentsView.addSubview(self.emotionNameLabel)
        self.emotionNameLabel.snp.makeConstraints {
            $0.top.equalTo(self.emotionImageView.snp.bottom).offset(4)
            $0.leading.equalTo(self.mainContentsView.snp.leading)
            $0.trailing.equalTo(self.mainContentsView.snp.trailing)
        }
    }
    
    private func refreshSelectedUI(_ emotion: Emotion) {
        self.emotionImageView.image = emotion.typeImage
        self.emotionNameLabel.textColor = Gen.Colors.black.color
    }
    
    private func refreshUnselectedUI(_ emotion: Emotion) {
        self.emotionImageView.image = emotion.typeNoImage
        self.emotionNameLabel.textColor = Gen.Colors.gray03.color
    }
    
    // MARK: internal function
    
    // MARK: action
}

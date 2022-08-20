//
//  ForegroundStep2TopView.swift
//  Archive
//
//  Created by hanwe on 2022/08/15.
//

import UIKit
import Then
import SnapKit
import RxCocoa
import RxSwift
import RxDataSources

@objc protocol ForegroundStep2TopViewDelegate: AnyObject {
    @objc optional func selectImage()
}

struct RegistCellData: Equatable {
    let index: Int
    let image: UIImage?
    let type: RegistCellType
    
    static func == (lhs: RegistCellData, rhs: RegistCellData) -> Bool {
        return lhs.index == rhs.index
    }
}

extension RegistCellData: IdentifiableType {
    typealias Identity = Int
    
    var identity: Identity {
        return Int.random(in: 0..<20000)
    }
}

enum RegistCellType: Int {
    case cover
    case image
    case addImage
}

struct RegistSetction: Equatable {
    let type: RegistCellType
    var items: [RegistCellData]
    var identity: Int {
        return type.rawValue
    }
}

extension RegistSetction: AnimatableSectionModelType {
    init(original: RegistSetction, items: [RegistCellData]) {
        self = original
        self.items = items
    }
}

class ForegroundStep2TopView: UIView {

    // MARK: private UI property
    
    private let mainContentsView = UIView().then {
        $0.backgroundColor = Gen.Colors.gray05.color
    }
    
    private let emotionCoverView = UIImageView().then {
        $0.image = Emotion.pleasant.coverAlphaImage
    }
    
    // empty
    
    private let emptyView = UIView().then {
        $0.backgroundColor = Gen.Colors.gray05.color
    }
    
    private let addIconImgView = UIImageView().then {
        $0.image = Gen.Images.addPhoto.image
    }
    
    private lazy var btn = UIButton().then {
        $0.backgroundColor = .clear
        $0.addTarget(self, action: #selector(clickedSelectImage), for: .touchUpInside)
    }
    
    // empty end
    
    private let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: UICollectionViewLayout()).then {
        $0.isPagingEnabled = true
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 1.621333333)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        $0.collectionViewLayout = layout
        $0.showsHorizontalScrollIndicator = false
    }
    
    private let upIconImgView = UIImageView().then {
        $0.image = Gen.Images.iconDropUp.image
    }
    
    // MARK: internal UI property
    
    // MARK: property
    
    var emotion: Emotion? {
        didSet {
            guard let emotion = self.emotion else { return }
            DispatchQueue.main.async { [weak self] in
                self?.refreshEmotionUI(emotion: emotion)
            }
        }
    }
    
    weak var delegate: ForegroundStep2TopViewDelegate?
    
    // MARK: private Property
    
    private let reactor: RegistReactor
    private let disposeBag = DisposeBag()
    
    
    typealias RegistSectionDataSource = RxCollectionViewSectionedReloadDataSource<RegistSetction>
    private lazy var dataSource: RegistSectionDataSource = {
        let configuration = AnimationConfiguration(insertAnimation: .automatic, reloadAnimation: .automatic, deleteAnimation: .automatic)
        
        let ds = RegistSectionDataSource { datasource, collectionView, indexPath, item in
            var cell: UICollectionViewCell?
            switch item.type {
            case .cover:
                cell = self.makeCoverCell(emotion: self.emotion,
                                          image: item.image ?? UIImage(),
                                          from: collectionView,
                                          indexPath: indexPath)
            case .image:
                cell = self.makeCardCell(image: item.image ?? UIImage(),
                                         from: collectionView,
                                         indexPath: indexPath)
            case .addImage:
                cell = self.makeAddCell(from: collectionView,
                                        indexPath: indexPath)
            }
            if let cell = cell {
                return cell
            } else {
                return UICollectionViewCell()
            }
        }
        return ds
    }()
    private var sections = BehaviorRelay<[RegistSetction]>(value: [])
    
    // MARK: lifeCycle
    
    init(reactor: RegistReactor) {
        self.reactor = reactor
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        setup()
        self.collectionView.register(RegistImageCollectionViewCell.self,
                                     forCellWithReuseIdentifier: RegistImageCollectionViewCell.identifier)
        self.collectionView.register(RegistImageAddCollectionViewCell.self,
                                     forCellWithReuseIdentifier: RegistImageAddCollectionViewCell.identifier)
        self.collectionView.register(RegistImageCoverCollectionViewCell.self,
                                     forCellWithReuseIdentifier: RegistImageCoverCollectionViewCell.identifier)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: private func
    
    private func setup() {
        self.backgroundColor = .clear
        
        self.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints {
            $0.edges.equalTo(self)
        }
        
        self.addSubview(self.mainContentsView)
        self.mainContentsView.snp.makeConstraints {
            $0.edges.equalTo(self)
        }
        
        self.mainContentsView.addSubview(self.emptyView)
        self.emptyView.snp.makeConstraints {
            $0.leading.equalTo(self.mainContentsView).offset(32)
            $0.trailing.equalTo(self.mainContentsView).offset(-32)
            $0.height.equalTo(UIScreen.main.bounds.width - 64)
            $0.bottom.equalTo(self.mainContentsView).offset(-75)
        }
        
        self.emptyView.addSubview(self.addIconImgView)
        self.addIconImgView.snp.makeConstraints {
            $0.width.height.equalTo(44)
            $0.center.equalTo(self.emptyView)
        }
        
        self.mainContentsView.addSubview(self.emotionCoverView)
        self.emotionCoverView.snp.makeConstraints {
            $0.edges.equalTo(self.emptyView)
        }
        
        self.emptyView.addSubview(self.btn)
        self.btn.snp.makeConstraints {
            $0.edges.equalTo(self.emptyView)
        }
        
        self.mainContentsView.addSubview(self.upIconImgView)
        self.upIconImgView.snp.makeConstraints {
            $0.width.height.equalTo(44)
            $0.bottom.equalTo(self.mainContentsView)
            $0.centerX.equalTo(self.mainContentsView)
        }
    }
    
    private func refreshEmotionUI(emotion: Emotion) {
        self.mainContentsView.backgroundColor = emotion.color
        self.emotionCoverView.image = emotion.coverAlphaImage
    }
    
    @objc private func clickedSelectImage() {
        self.delegate?.selectImage?()
    }
    
    private func makeCardCell(image: UIImage, from collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RegistImageCollectionViewCell.identifier, for: indexPath) as? RegistImageCollectionViewCell else { return UICollectionViewCell() }
        cell.image = image
        return cell
    }
    
    private func makeAddCell(from collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RegistImageAddCollectionViewCell.identifier, for: indexPath) as? RegistImageAddCollectionViewCell else { return UICollectionViewCell() }
        return cell
    }
    
    private func makeCoverCell(emotion: Emotion?, image: UIImage, from collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RegistImageCoverCollectionViewCell.identifier, for: indexPath) as? RegistImageCoverCollectionViewCell else { return UICollectionViewCell() }
        cell.emotion = emotion
        cell.image = image
        return cell
    }
    
    // MARK: func
    
    func bind() {
        
        self.collectionView.dataSource = nil
        
        sections.bind(to: self.collectionView.rx.items(dataSource: dataSource))
            .disposed(by: self.disposeBag)
        
        reactor.state
            .map { $0.images }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: [])
            .drive(onNext: { [weak self] images in
                var arr: [RegistCellData] = []
                for i in 0..<images.count {
                    let item = images[i]
                    if i == 0 {
                        arr.append(RegistCellData(index: 0, image: item, type: .cover))
                    } else {
                        arr.append(RegistCellData(index: i - 1, image: item, type: .image))
                    }
                }
                arr.append(RegistCellData(index: 0, image: nil, type: .addImage))
                self?.sections.accept([RegistSetction(type: .image, items: arr)])
            })
            .disposed(by: self.disposeBag)
    }
    
    func hideEmptyView() {
        self.mainContentsView.isHidden = true
    }

}

class ForegroundStep2TopViewDelegateProxy: DelegateProxy<ForegroundStep2TopView, ForegroundStep2TopViewDelegate>, DelegateProxyType, ForegroundStep2TopViewDelegate {
    
    
    static func currentDelegate(for object: ForegroundStep2TopView) -> ForegroundStep2TopViewDelegate? {
        return object.delegate
    }
    
    static func setCurrentDelegate(_ delegate: ForegroundStep2TopViewDelegate?, to object: ForegroundStep2TopView) {
        object.delegate = delegate
    }
    
    static func registerKnownImplementations() {
        self.register { (view) -> ForegroundStep2TopViewDelegateProxy in
            ForegroundStep2TopViewDelegateProxy(parentObject: view, delegateProxy: self)
        }
    }
}

extension Reactive where Base: ForegroundStep2TopView {
    var delegate: DelegateProxy<ForegroundStep2TopView, ForegroundStep2TopViewDelegate> {
        return ForegroundStep2TopViewDelegateProxy.proxy(for: self.base)
    }
    
    var selectImage: Observable<Void> {
        return delegate.methodInvoked(#selector(ForegroundStep2TopViewDelegate.selectImage))
            .map { result in
                return ()
            }
    }
}

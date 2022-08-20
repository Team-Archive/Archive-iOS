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

@objc protocol ForegroundStep2TopViewDelegate: AnyObject {
    @objc optional func selectImage()
}

class ForegroundStep2TopView: UIView {
    
    enum CellModel {
        case cover(UIImage)
        case commonImage(ImageInfo)
        case addImage(Void)
    }

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
    
    // MARK: private Property
    
    weak var delegate: ForegroundStep2TopViewDelegate?
    let reactor: RegistReactor
    
    // MARK: lifeCycle
    
    init(reactor: RegistReactor) {
        self.reactor = reactor
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: private func
    
    private func setup() {
        self.backgroundColor = .clear
        
        self.addSubview(self.mainContentsView)
        self.mainContentsView.snp.makeConstraints {
            $0.edges.equalTo(self)
        }
        
        self.mainContentsView.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints {
            $0.leading.equalTo(self.mainContentsView).offset(32)
            $0.trailing.equalTo(self.mainContentsView).offset(-32)
            $0.height.equalTo(UIScreen.main.bounds.width - 64)
            $0.bottom.equalTo(self.mainContentsView).offset(-75)
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
    
    // MARK: func
    
    func bind() {
        guard let reactor = reactor else { return }
        
//        reactor.state.map { $0.images }
//            .distinctUntilChanged()
//            .asDriver(onErrorJustReturn: [])
//            .drive(onNext: { [weak self] images in
//                print("images: \(images)")
//                self?.imagesCollectionView.delegate = nil
//                self?.imagesCollectionView.dataSource = nil
//                let cardImage = images[0]
//                let images = images
////                self?.pageControl.numberOfPages = images.count + 2
////                self?.defaultImageContainerView.isHidden = true
////                self?.imagesCollectionView.isHidden = false
////                self?.topContentsContainerView.backgroundColor = .clear
//                var imageCellArr: [CellModel] = []
//                for imageItem in images {
//                    imageCellArr.append(CellModel.commonImage(imageItem))
//                }
//                let sections = Observable.just([
//                    SectionModel(model: "card", items: [
//                        CellModel.cover(cardImage)
//                    ]),
//                    SectionModel(model: "image", items: imageCellArr),
//                    SectionModel(model: "addImage", items: [CellModel.addImage(())])
//                ])
//                guard let self = self else { return }
//                let dataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, CellModel>>(configureCell: { dataSource, collectionView, indexPath, item in
//                    switch item {
//                    case .cover(let image):
//                        return self.makeCardCell(emotion: reactor.currentState.emotion, with: image, from: collectionView, indexPath: indexPath)
//                    case .commonImage(let imageInfo):
//                        return self.makeImageCell(emotion: reactor.currentState.emotion, with: imageInfo, from: collectionView, indexPath: indexPath)
//                    case .addImage:
//                        return self.makeAddImageCell(from: collectionView, indexPath: indexPath)
//                    }
//                })
//                let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
//                layout.minimumLineSpacing = 0
//                layout.minimumInteritemSpacing = 0
//                layout.scrollDirection = .horizontal
//                layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: self.imagesCollectionView.bounds.height)
//                layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//                self.imagesCollectionView.collectionViewLayout = layout
//                sections
//                    .bind(to: self.imagesCollectionView.rx.items(dataSource: dataSource))
//                    .disposed(by: self.disposeBag)
//            })
//            .disposed(by: self.disposeBag)
    }
    
    func hideEmptyView() {
        self.emptyView.isHidden = true
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

//
//  ForegroundStep3TopView.swift
//  Archive
//
//  Created by hanwe on 2022/08/15.
//

import UIKit
import Then
import SnapKit
import RxCocoa
import RxSwift

class ForegroundStep3TopView: UIView {
    
    enum CellModel {
        case cover(UIImage)
        case commonImage(ImageInfo)
        case addImage(Void)
    }

    // MARK: private UI property
    
    private let mainContentsView = UIView().then {
        $0.backgroundColor = Gen.Colors.gray05.color
    }
    
    private let imagesCollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: UICollectionViewLayout()).then {
        $0.isPagingEnabled = true
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 1.621333333)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        $0.collectionViewLayout = layout
    }
    
    // MARK: internal UI property
    
    // MARK: property
    
    var reactor: RegistReactor?
    
    // MARK: private Property
    
    let disposeBag = DisposeBag()
    
    // MARK: lifeCycle
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        setup()
    }
    
    // MARK: private func
    
    private func setup() {
        self.backgroundColor = .clear
        
        self.addSubview(self.mainContentsView)
        self.mainContentsView.snp.makeConstraints {
            $0.edges.equalTo(self)
        }
        
        self.mainContentsView.addSubview(self.imagesCollectionView)
        self.imagesCollectionView.snp.makeConstraints {
            $0.edges.equalTo(self.mainContentsView)
        }
    }
    
//    private func makeImageInfos(_ images: [UIImage], completion: @escaping ([ImageInfo]) -> Void) {
//        var returnValue: [ImageInfo] = [ImageInfo]()
//        resize(images: images, scale: 0.2, completion: { [weak self] resizedImages in
//            for i in 0..<images.count {
//                let item: ImageInfo = ImageInfo(originalImage: images[i], image: images[i], backgroundColor: resizedImages[i].getColors()?.background ?? .clear, contents: nil)
//                returnValue.append(item)
//            }
//            completion(returnValue)
//        })
//    }
    
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

}

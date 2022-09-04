//
//  DetailViewController.swift
//  Archive
//
//  Created by hanwe on 2021/12/04.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa
import RxDataSources
import SnapKit

protocol DetailViewControllerDelegate: AnyObject {
    func deletedArchive()
    func willDeletedArchive(index: Int)
}

class DetailViewController: UIViewController, StoryboardView, ActivityIndicatorable {
    
    enum DetailType {
        case home
        case myLike
    }
    
    enum CellModel {
        case cover(ArchiveDetailInfo)
        case commonImage(ArchiveDetailImageInfo, Emotion, String)
    }
    
    // MARK: IBOutlet
    @IBOutlet weak var mainBackgroundView: UIView!
    
    @IBOutlet weak var mainContainerView: UIView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    // MARK: private property
    
    private let modalShareViewController: ModalShareViewController = ModalShareViewController.init(nibName: "ModalShareViewController", bundle: nil)
    private var willDisplayIndex: Int = 0
    
    private lazy var dataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, CellModel>>(configureCell: { [weak self] dataSource, collectionView, indexPath, item in
        switch item {
        case .cover(let infoData):
            return self?.makeCardCell(with: infoData, from: collectionView, indexPath: indexPath) ?? UICollectionViewCell()
        case .commonImage(let imageInfo, let emotion, let name):
            return self?.makeImageCell(with: imageInfo, emotion: emotion, name: name, from: collectionView, indexPath: indexPath) ?? UICollectionViewCell()
        }
    })
    
    private let type: DetailType
    
    // MARK: internal property
    var disposeBag: DisposeBag = DisposeBag()
    
    weak var delegate: DetailViewControllerDelegate?
    
    // MARK: lifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }
    
    deinit {
        print("\(self) deinit")
    }
    
    init?(coder: NSCoder, reactor: DetailReactor, type: DetailType = .home) {
        self.type = type
        super.init(coder: coder)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(reactor: DetailReactor) {
        
        reactor.state
            .map { $0.detailData }
            .asDriver(onErrorJustReturn: nil)
            .compactMap { $0 }
            .drive(onNext: { [weak self] info in
                guard let images = info.images else { return }
                self?.pageControl.numberOfPages = images.count + 1
            })
            .disposed(by: self.disposeBag)
        
        reactor.state
            .map { $0.detailData }
            .compactMap { $0 }
            .distinctUntilChanged()
            .map { [weak self] info -> [CellModel] in
                var returnValue: [CellModel] = []
                returnValue.append(.cover(info))
                guard let images = info.images else { return [] }
                for imageItem in images {
                    returnValue.append(CellModel.commonImage(imageItem, info.emotion, info.name))
                }
                let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
                layout.minimumLineSpacing = 0
                layout.minimumInteritemSpacing = 0
                layout.scrollDirection = .horizontal
                let width = UIScreen.main.bounds.width
                let height = UIScreen.main.bounds.height
                layout.itemSize = CGSize(width: width, height: height)
                layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                self?.collectionView.collectionViewLayout = layout
                return returnValue
            }
            .flatMap { info -> Observable<[SectionModel]> in
                return .just([.init(model: "", items: info)])
            }
            .bind(to: self.collectionView.rx.items(dataSource: dataSource))
            .disposed(by: self.disposeBag)
        
        self.collectionView.rx.didEndDisplayingCell
            .asDriver()
            .drive(onNext: { [weak self] info in
                let index: Int = info.at.item
                if index != (self?.willDisplayIndex ?? 0) {
                    self?.pageControl.currentPage = self?.willDisplayIndex ?? 0
                }
            })
            .disposed(by: self.disposeBag)
        
        self.collectionView.rx.willDisplayCell
            .subscribe(onNext: { [weak self] info in
                self?.willDisplayIndex = info.at.item
            })
            .disposed(by: self.disposeBag)
        
        reactor.state
            .map { $0.shareActivityController }
            .asDriver(onErrorJustReturn: nil)
            .compactMap { $0 }
            .drive(onNext: { [weak self] controller in
                self?.modalShareViewController.dismiss(animated: false, completion: { [weak self] in
                    controller.isModalInPresentation = true
                    controller.excludedActivityTypes = [.airDrop, .message]
                    self?.present(controller, animated: true, completion: nil)
                })
            })
            .disposed(by: self.disposeBag)
        
        reactor.state
            .map { $0.isLoading }
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] isLoading in
                if isLoading {
                    self?.startIndicatorAnimating()
                } else {
                    self?.stopIndicatorAnimating()
                }
            })
            .disposed(by: self.disposeBag)
        
        reactor.state
            .map { $0.isDeletedArchive }
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] isDeleted in
                if isDeleted {
                    self?.delegate?.deletedArchive()
                    self?.dismiss(animated: true, completion: nil)
                }
            })
            .disposed(by: self.disposeBag)
    }
    
    // MARK: private function
    
    private func initUI() {
        self.mainBackgroundView.backgroundColor = Gen.Colors.gray04.color
        self.mainContainerView.backgroundColor = .clear
        self.collectionView.backgroundColor = .clear
        
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.register(UINib(nibName: DetailCardCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: DetailCardCollectionViewCell.identifier)
        self.collectionView.register(UINib(nibName: DetailContentsCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: DetailContentsCollectionViewCell.identifier)
        
        self.pageControl.pageIndicatorTintColor = Gen.Colors.gray03.color
        self.pageControl.currentPageIndicatorTintColor = Gen.Colors.gray01.color
        self.pageControl.isEnabled = false
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.navigationBar.tintColor = .white
        
        makeNaviBtn()
    }
    
    private func makeCardCell(with element: ArchiveDetailInfo, from collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DetailCardCollectionViewCell.identifier, for: indexPath) as? DetailCardCollectionViewCell else { return UICollectionViewCell() }
        cell.infoData = element
        cell.topContainerViewHeightConstraint.constant = self.topbarHeight
        return cell
    }
    
    private func makeImageCell(with element: ArchiveDetailImageInfo, emotion: Emotion, name: String, from collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DetailContentsCollectionViewCell.identifier, for: indexPath) as? DetailContentsCollectionViewCell else { return UICollectionViewCell() }
        cell.infoData = element
        cell.topContainerViewHeightConstraint.constant = self.topbarHeight
        cell.emotion = emotion
        cell.name = name
        return cell
    }
    
    private func makeNaviBtn() {
        switch self.type {
        case .home:
            let moreImage = Gen.Images.moreVertBlack24dp.image
            moreImage.withRenderingMode(.alwaysTemplate)
            let moreBarButtonItem = UIBarButtonItem(image: moreImage, style: .plain, target: self, action: #selector(moreButtonClicked(_:)))
            moreBarButtonItem.tintColor = Gen.Colors.white.color
            self.navigationItem.rightBarButtonItem = moreBarButtonItem
        case .myLike:
            break
        }
        
        let closeImage = Gen.Images.xIcon.image
        closeImage.withRenderingMode(.alwaysTemplate)
        let backBarButtonItem = UIBarButtonItem(image: closeImage, style: .plain, target: self, action: #selector(backButtonClicked(_:)))
        backBarButtonItem.tintColor = Gen.Colors.white.color
        self.navigationItem.leftBarButtonItem = backBarButtonItem
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: Gen.Colors.white.color]
    }
    
    // MARK: internal function
    
    // MARK: action
    
    @objc private func moreButtonClicked(_ sender: UIButton) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let deleteAction: UIAlertAction = UIAlertAction(title: "삭제", style: .default) { (delete) in
            CommonAlertView.shared.show(message: "기록을 삭제하겠습니까?", subMessage: "삭제된 이미지와 글은 복구가 불가능합니다.", confirmBtnTxt: "삭제", cancelBtnTxt: "취소", confirmHandler: { [weak self] in
                CommonAlertView.shared.hide(nil)
                self?.delegate?.willDeletedArchive(index: self?.reactor?.getIndex() ?? -1)
                self?.reactor?.action.onNext(.deleteArchive)
            }, cancelHandler: {
                CommonAlertView.shared.hide(nil)
            })
        }
        let shareAction: UIAlertAction = UIAlertAction(title: "공유", style: .default) { [weak self] (share) in
            self?.modalShareViewController.modalPresentationStyle = .overFullScreen
            self?.modalShareViewController.delegate = self
            self?.present(self!.modalShareViewController, animated: false, completion: {
                self?.modalShareViewController.fadeIn()
            })
        }
        alert.view.tintColor = .black
        alert.addAction(deleteAction)
        alert.addAction(shareAction)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    @objc private func backButtonClicked(_ sender: UIButton) {
        self.dismiss(animated: true)
    }

}

extension DetailViewController: ModalShareViewControllerDelegate {
    func instagramShareClicked() {
        self.reactor?.action.onNext(.shareToInstagram)
    }
    
    func photoShareClicked() {
        self.reactor?.action.onNext(.saveToAlbum)
    }
}

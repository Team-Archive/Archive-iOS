//
//  ImageRecordViewController.swift
//  Archive
//
//  Created by hanwe on 2021/10/25.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa
import RxDataSources
import SnapKit
import CropViewController

protocol ImageRecordViewControllerProtocol: AnyObject {
    func setRecordTitle(_ title: String)
    func hideTopView()
    func showTopView()
    
    var reactor: ImageRecordReactor? { get }
    var delegate: ImageRecordViewControllerDelegate? { get set }
}

protocol ImageRecordViewControllerDelegate: AnyObject {
    func clickedEmotionSelectArea(currentEmotion: Emotion?)
    func clickedPhotoSeleteArea()
    func clickedContentsArea()
    func addMorePhoto()
    func settedImageInfos(infos: [ImageInfo])
}

class ImageRecordViewController: UIViewController, StoryboardView, ImageRecordViewControllerProtocol, ActivityIndicatorable {
    
    enum CellModel {
        case cover(UIImage)
        case commonImage(ImageInfo)
        case addImage(Void)
    }
    
    // MARK: IBOutlet
    @IBOutlet weak var mainBackgroundView: UIView!
    @IBOutlet weak var scrollContainerView: UIView!
    @IBOutlet weak var scrollContainerViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mainContainerView: UIView!
    @IBOutlet weak var naviShadowViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var topContainerBackgroundView: UIView!
    @IBOutlet weak var topContainerView: UIView!
    @IBOutlet weak var emotionMainImageView: UIImageView!
    @IBOutlet weak var topContentsContainerView: UIView!
    @IBOutlet weak var defaultImageContainerView: UIView!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var emotionSelectView: UIView!
    @IBOutlet weak var emotionSelectBtn: UIButton!
    @IBOutlet weak var miniEmotionImageView: UIImageView!
    @IBOutlet weak var emotionLabel: UILabel!
    @IBOutlet weak var addPhotoImgView: UIImageView!
    @IBOutlet weak var addPhotoBtn: UIButton!
    
    @IBOutlet weak var bottomContainerView: UIView!
    @IBOutlet weak var helpLabel: UILabel!
    @IBOutlet weak var doWriteLabel: UILabel!
    @IBOutlet weak var bottomBtn: UIButton!
    
    @IBOutlet weak var imagesCollectionView: UICollectionView!
    
    @IBOutlet weak var pageControl: UIPageControl!
    // MARK: private property
    
    private let photoContentsView: PhotoContentsView? = PhotoContentsView.instance()
    private let dummyContentsView: UIView = UIView()
    private var willDisplayIndex: Int = 0
    private var willDisplaySectionIndex: Int = 0
    private var originMainContainerViewBottomConstraint: CGFloat = 0
    
    // MARK: internal property
    
    weak var delegate: ImageRecordViewControllerDelegate?
    
    var disposeBag: DisposeBag = DisposeBag()
    
    // MARK: lifeCycle
    
    init?(coder: NSCoder, reactor: ImageRecordReactor) {
        super.init(coder: coder)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.navigationBar.tintColor = .white
    }
    
    func bind(reactor: ImageRecordReactor) {
        self.addPhotoBtn.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.delegate?.clickedPhotoSeleteArea()
            })
            .disposed(by: self.disposeBag)
        
        self.emotionSelectBtn.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.delegate?.clickedEmotionSelectArea(currentEmotion: reactor.currentState.emotion)
            })
            .disposed(by: self.disposeBag)
        
        self.bottomBtn.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.delegate?.clickedContentsArea()
            })
            .disposed(by: self.disposeBag)
        
        reactor.state
            .map { $0.emotion }
            .asDriver(onErrorJustReturn: nil)
            .compactMap { $0 }
            .drive(onNext: { [weak self] emotion in
                self?.addPhotoImgView.isHidden = false
                self?.addPhotoBtn.isHidden = false
                self?.coverImageView.image = emotion.coverImage
                self?.topContainerView.backgroundColor = emotion.color
                self?.miniEmotionImageView.image = emotion.miniImage
                self?.emotionLabel.text = emotion.localizationTitle
            })
            .disposed(by: self.disposeBag)
            
        
        Observable.zip(reactor.state.map { $0.thumbnailImage }, reactor.state.map { $0.imageInfos }.map { $0 })
            .asDriver(onErrorJustReturn: (nil, nil))
            .drive(onNext: {[weak self] zippedImages in
                self?.imagesCollectionView.delegate = nil
                self?.imagesCollectionView.dataSource = nil
                guard let cardImage = zippedImages.0 else { return }
                guard let images = zippedImages.1 else { return }
                self?.pageControl.numberOfPages = images.count + 2
                self?.defaultImageContainerView.isHidden = true
                self?.imagesCollectionView.isHidden = false
                self?.topContentsContainerView.backgroundColor = .clear
                var imageCellArr: [CellModel] = []
                for imageItem in images {
                    imageCellArr.append(CellModel.commonImage(imageItem))
                }
                let sections = Observable.just([
                    SectionModel(model: "card", items: [
                        CellModel.cover(cardImage)
                    ]),
                    SectionModel(model: "image", items: imageCellArr),
                    SectionModel(model: "addImage", items: [CellModel.addImage(())])
                ])
                guard let self = self else { return }
                let dataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, CellModel>>(configureCell: { dataSource, collectionView, indexPath, item in
                    switch item {
                    case .cover(let image):
                        return self.makeCardCell(emotion: reactor.currentState.emotion, with: image, from: collectionView, indexPath: indexPath)
                    case .commonImage(let imageInfo):
                        return self.makeImageCell(emotion: reactor.currentState.emotion, with: imageInfo, from: collectionView, indexPath: indexPath)
                    case .addImage:
                        return self.makeAddImageCell(from: collectionView, indexPath: indexPath)
                    }
                })
                let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
                layout.minimumLineSpacing = 0
                layout.minimumInteritemSpacing = 0
                layout.scrollDirection = .horizontal
                layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: self.imagesCollectionView.bounds.height)
                layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                self.imagesCollectionView.collectionViewLayout = layout
                sections
                    .bind(to: self.imagesCollectionView.rx.items(dataSource: dataSource))
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: self.disposeBag)
        
        self.imagesCollectionView.rx.willDisplayCell
            .asDriver()
            .compactMap { $0 }
            .drive(onNext: { [weak self] item in
                if item.at.section == 0 {
                    self?.emotionSelectView.isHidden = false
                } else {
                    self?.emotionSelectView.isHidden = true
                }
            })
            .disposed(by: self.disposeBag)
        
        self.imagesCollectionView.rx.itemSelected
            .asDriver()
            .compactMap { $0 }
            .drive(onNext: { [weak self] selectedItem in
                if selectedItem.section == 2 {
                    self?.delegate?.addMorePhoto()
                }
            })
            .disposed(by: self.disposeBag)
        
        self.imagesCollectionView.rx.willDisplayCell
            .asDriver()
            .drive(onNext: { [weak self] info in
                if info.at.section == 0 {
                    self?.photoContentsView?.isHidden = true
                    self?.dummyContentsView.isHidden = true
                } else if info.at.section == 1 {
                    self?.photoContentsView?.isHidden = false
                    self?.dummyContentsView.isHidden = true
                    if let imageInfo = reactor.currentState.imageInfos?[info.at.item] {
                        self?.photoContentsView?.imageInfo = imageInfo
                        self?.photoContentsView?.index = info.at.item
                    }
                } else {
                    self?.photoContentsView?.isHidden = true
                    self?.dummyContentsView.isHidden = false
                }
            })
            .disposed(by: self.disposeBag)
        
        self.imagesCollectionView.rx.didEndDisplayingCell
            .asDriver()
            .drive(onNext: { [weak self] info in
                var index: Int = 0
                if info.at.section != 2 && (self?.willDisplaySectionIndex ?? 0) == 2 {
                    self?.pageControl.currentPage = (self?.pageControl.numberOfPages ?? 1) - 1
                } else {
                    if info.at.section != 0 {
                        index = info.at.item + 1
                    }
                    if index != (self?.willDisplayIndex ?? 0) {
                        self?.pageControl.currentPage = self?.willDisplayIndex ?? 0
                    }
                }
            })
            .disposed(by: self.disposeBag)
        
        self.imagesCollectionView.rx.willDisplayCell
            .subscribe(onNext: { [weak self] info in
                self?.willDisplaySectionIndex = info.at.section
                if info.at.section == 0 {
                    self?.willDisplayIndex = 0
                } else {
                    self?.willDisplayIndex = info.at.item + 1
                }
            })
            .disposed(by: self.disposeBag)
        
        reactor.isLoading
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
            .map { $0.imageInfos }
            .compactMap { $0 }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] infos in
                self?.delegate?.settedImageInfos(infos: infos)
            })
            .disposed(by: self.disposeBag)
        
    }
    
    // MARK: private function
    
    private func initUI() {
        self.mainBackgroundView.backgroundColor = Gen.Colors.white.color
        self.scrollContainerView.backgroundColor = .clear
        self.scrollView.backgroundColor = .clear
        self.mainContainerView.backgroundColor = .clear
        self.topContainerBackgroundView.backgroundColor = Gen.Colors.gray05.color
        self.topContainerView.backgroundColor = .clear
        self.topContentsContainerView.backgroundColor = .clear
        self.emotionSelectView.backgroundColor = .clear
        self.emotionSelectView.layer.cornerRadius = 8
        self.emotionSelectView.layer.borderWidth = 1
        self.emotionSelectView.layer.borderColor = Gen.Colors.black.color.cgColor
        
        self.emotionLabel.font = .fonts(.subTitle)
        self.emotionLabel.textColor = Gen.Colors.black.color
        self.emotionLabel.text = "전시가 어땠나요?"
        
        self.bottomContainerView.backgroundColor = Gen.Colors.white.color
        
        self.helpLabel.font = .fonts(.subTitle)
        self.helpLabel.textColor = Gen.Colors.black.color
        self.helpLabel.text = "무슨 전시를 감상했나요?"
        
        self.doWriteLabel.font = .fonts(.header2)
        self.doWriteLabel.textColor = Gen.Colors.gray03.color
        self.doWriteLabel.text = "전시명을 입력해주세요."
        
        self.addPhotoImgView.isHidden = true
        self.addPhotoBtn.isHidden = true
        self.imagesCollectionView.showsHorizontalScrollIndicator = false
        self.imagesCollectionView.isHidden = true
        self.imagesCollectionView.register(UINib(nibName: RecordCardCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: RecordCardCollectionViewCell.identifier)
        self.imagesCollectionView.register(UINib(nibName: RecordImageCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: RecordImageCollectionViewCell.identifier)
        self.imagesCollectionView.register(UINib(nibName: RecordAddImageCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: RecordAddImageCollectionViewCell.identifier)
        
        if let photoContentsView = self.photoContentsView {
            self.bottomContainerView.addSubview(photoContentsView)
            photoContentsView.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
            photoContentsView.isHidden = true
            photoContentsView.delegate = self
        }
        
        self.bottomContainerView.addSubview(self.dummyContentsView)
        self.dummyContentsView.backgroundColor = Gen.Colors.white.color
        dummyContentsView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        dummyContentsView.isHidden = true
        
        self.pageControl.numberOfPages = 0
        self.pageControl.pageIndicatorTintColor = Gen.Colors.gray03.color
        self.pageControl.currentPageIndicatorTintColor = Gen.Colors.gray01.color
        self.pageControl.isEnabled = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.naviShadowViewHeightConstraint.constant = self.topbarHeight
        
        
    }
    
    private func makeCardCell(emotion: Emotion?, with element: UIImage, from collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = imagesCollectionView.dequeueReusableCell(withReuseIdentifier: RecordCardCollectionViewCell.identifier, for: indexPath) as? RecordCardCollectionViewCell else { return UICollectionViewCell() }
        cell.mainImageView.image = element
        cell.emotion = emotion
        return cell
    }
    
    private func makeImageCell(emotion: Emotion?, with element: ImageInfo, from collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = imagesCollectionView.dequeueReusableCell(withReuseIdentifier: RecordImageCollectionViewCell.identifier, for: indexPath) as? RecordImageCollectionViewCell else { return UICollectionViewCell() }
        cell.index = indexPath.item
        cell.imageInfo = element
        cell.emotion = emotion
        cell.delegate = self
        return cell
    }
    
    private func makeAddImageCell(from collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = imagesCollectionView.dequeueReusableCell(withReuseIdentifier: RecordAddImageCollectionViewCell.identifier, for: indexPath) as? RecordAddImageCollectionViewCell else { return UICollectionViewCell() }
        return cell
    }
    
    private func showImageEditView(image: UIImage, index: Int) {
        let cropViewController: CropViewController = CropViewController(croppingStyle: .default, image: image)
        cropViewController.delegate = self
        cropViewController.doneButtonTitle = "확인"
        cropViewController.doneButtonColor = Gen.Colors.white.color
        cropViewController.cancelButtonTitle = "취소"
        cropViewController.cancelButtonColor = Gen.Colors.white.color
        self.present(cropViewController, animated: true, completion: nil)
        cropViewController.cropView.tag = index
    }
    
    // MARK: internal function
    
    func setRecordTitle(_ title: String) {
        DispatchQueue.main.async { [weak self] in
            self?.doWriteLabel.text = title
            self?.doWriteLabel.textColor = Gen.Colors.black.color
        }
    }
    
    func hideTopView() {
        self.topContainerView.isHidden = true
    }
    
    func showTopView() {
        self.topContainerView.isHidden = false
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardHeight = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height else { return }
        var added: CGFloat = 0
        if UIDevice.current.hasNotch {
            added = 34
        }
        self.scrollContainerViewBottomConstraint.constant = keyboardHeight - added
        let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.height + scrollView.contentInset.bottom + keyboardHeight - added)
        self.scrollView.setContentOffset(bottomOffset, animated: true)
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        self.scrollContainerViewBottomConstraint.constant = self.originMainContainerViewBottomConstraint
        UIView.animate(withDuration: 1.0, animations: { [weak self] in
            self?.view.layoutIfNeeded()
            self?.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        })
    }
    
    // MARK: action
    
    
}

extension ImageRecordViewController: PhotoContentsViewDelegate {
    func photoCellContentsConfirmed(text: String?, index: Int) {
        if var infos = self.reactor?.currentState.imageInfos {
            infos[index].contents = text
            self.reactor?.action.onNext(.setImageInfos(infos))
            self.imagesCollectionView.scrollToItem(at: IndexPath(item: index, section: 1), at: .left, animated: false)
        }
    }
}

extension ImageRecordViewController: RecordImageCollectionViewCellDelegate {
    func imageCrop(image: UIImage, index: Int) {
        showImageEditView(image: image, index: index)
    }
}

extension ImageRecordViewController: CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        DispatchQueue.main.async { [weak self] in
            cropViewController.dismiss(animated: true, completion: { [weak self] in
                if var infos = self?.reactor?.currentState.imageInfos {
                    infos[cropViewController.cropView.tag].image = image
                    self?.reactor?.action.onNext(.setImageInfos(infos))
                    self?.imagesCollectionView.scrollToItem(at: IndexPath(item: cropViewController.cropView.tag, section: 1), at: .left, animated: false)
                }
            })
        }
    }
}

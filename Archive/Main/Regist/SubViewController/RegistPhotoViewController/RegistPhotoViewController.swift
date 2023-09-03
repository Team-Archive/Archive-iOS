//
//  RegistPhotoViewController.swift
//  Archive
//
//  Created by hanwe on 2022/08/15.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa
import SnapKit
import Then
import Photos
import CropViewController

protocol RegistPhotoViewControllerDelegate: AnyObject {
  func selectedImages(images: [RegistImageInfo], origin: [PHAsset: PhotoFromAlbumModel])
}

class RegistPhotoViewController: UIViewController, View, ActivityIndicatorable {
  
  // MARK: UIProperty
  
  private let mainBackgroundView = UIView().then {
    $0.backgroundColor = Gen.Colors.white.color
  }
  
  private let mainContentsView = UIView().then {
    $0.backgroundColor = .clear
  }
  
  private let imageThumbnailContainerView = UIView().then {
    $0.backgroundColor = .clear
  }
  
  private let thumbnailImageView = UIImageView().then {
    $0.backgroundColor = .clear
    $0.contentMode = .scaleAspectFit
  }
  
  private let imageAlbumContainerView = UIView().then {
    $0.backgroundColor = .clear
  }
  
  private let registPhotoSelectAlbumButtonView: RegistPhotoSelectAlbumButtonView = RegistPhotoSelectAlbumButtonView()
  private var albumSelectorViewController: AlbumSelectorViewController
  private lazy var albumSelectorNavigation = UINavigationController(rootViewController: albumSelectorViewController)
  private lazy var albumView: HWPhotoListFromAlbumView? = HWPhotoListFromAlbumView.loadFromNibNamed(nibNamed: "HWPhotoListFromAlbumView")?.then {
    $0.delegate = self
    $0.selectType = .multi
    $0.selectedIndexDic = self.reactor?.currentState.originPhotoInfo ?? [:]
  }
  
  // MARK: private property
  
  private var confirmBtn: UIBarButtonItem?
  
  // MARK: internal property
  
  var disposeBag: DisposeBag = DisposeBag()
  
  weak var delegate: RegistPhotoViewControllerDelegate?
  
  // MARK: lifeCycle
  
  init(reactor: RegistPhotoReactor) {
    self.albumSelectorViewController = AlbumSelectorViewController(list: RegistPhotoViewController.fetchAlbumList())
    super.init(nibName: nil, bundle: nil)
    self.albumSelectorViewController.delegate = self
    self.reactor = reactor
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  deinit {
    print("\(self) deinit")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    makeNavigationItems()
    self.albumView?.setFetchAsset(fetchResult: self.fetchAllPhotoAssets())
  }
  
  override func loadView() {
    super.loadView()
    setup()
  }
  
  func bind(reactor: RegistPhotoReactor) {
    reactor.state
      .map { $0.thumbnailImage }
      .distinctUntilChanged()
      .asDriver(onErrorJustReturn: UIImage())
      .drive(onNext: { [weak self] image in
        self?.thumbnailImageView.image = image
      })
      .disposed(by: self.disposeBag)
    
    reactor.state
      .map { $0.selectedImageArr }
      .distinctUntilChanged()
      .asDriver(onErrorJustReturn: [])
      .drive(onNext: { [weak self] imageArr in
        if imageArr.count == 0 { return }
        if reactor.currentState.isUsingCover {
          self?.showImageCoverTypeEditView(image: imageArr[0])
        } else {
          self?.showImageImageTypeEditView(image: imageArr[0])
        }
      })
      .disposed(by: self.disposeBag)
    
    reactor.state
      .map { $0.isLoading }
      .distinctUntilChanged()
      .asDriver(onErrorJustReturn: false)
      .drive(onNext: { [weak self] in
        if $0 {
          self?.startIndicatorAnimating()
        } else {
          self?.stopIndicatorAnimating()
        }
      })
      .disposed(by: self.disposeBag)
    
    reactor.completedImages
      .asDriver(onErrorJustReturn: [])
      .drive(onNext: { [weak self] imageInfos in
        self?.delegate?.selectedImages(images: imageInfos, origin: reactor.currentState.originPhotoInfo)
        self?.dismiss(animated: true)
      })
      .disposed(by: self.disposeBag)
    
    self.registPhotoSelectAlbumButtonView.rx.requestSelectAlbum
      .asDriver(onErrorJustReturn: ())
      .drive(onNext: { [weak self] in
        guard let vc = self?.albumSelectorNavigation else { return }
        vc.modalPresentationStyle = .fullScreen
        self?.present(vc, animated: true)
      })
      .disposed(by: self.disposeBag)
    
  }
  
  // MARK: private function
  
  private func setup() {
    self.view.addSubview(self.mainBackgroundView)
    self.mainBackgroundView.snp.makeConstraints {
      $0.edges.equalTo(self.view)
    }
    
    self.view.addSubview(self.mainContentsView)
    let safeGuide = self.view.safeAreaLayoutGuide
    self.mainContentsView.snp.makeConstraints {
      $0.edges.equalTo(safeGuide)
    }
    
    self.mainContentsView.addSubview(self.imageThumbnailContainerView)
    self.imageThumbnailContainerView.snp.makeConstraints {
      $0.top.leading.trailing.equalTo(self.mainContentsView)
      $0.height.equalTo(UIScreen.main.bounds.width)
    }
    
    self.imageThumbnailContainerView.addSubview(self.thumbnailImageView)
    self.thumbnailImageView.snp.makeConstraints {
      $0.edges.equalTo(self.imageThumbnailContainerView)
    }
    
    self.mainContentsView.addSubview(self.imageAlbumContainerView)
    self.imageAlbumContainerView.snp.makeConstraints {
      $0.leading.trailing.bottom.equalTo(self.mainContentsView)
      $0.top.equalTo(self.imageThumbnailContainerView.snp.bottom)
    }
    
    if let albumView {
      self.imageAlbumContainerView.addSubview(albumView)
      albumView.snp.makeConstraints { (make) in
        make.edges.equalTo(self.imageAlbumContainerView)
      }
    }
    
  }
  
  private func makeNavigationItems() {
    self.confirmBtn = UIBarButtonItem(title: "선택", style: .plain, target: self, action: #selector(confirmAction(_:)))
    setConfirmBtnColor(Gen.Colors.gray04.color)
    
    let cancelBtn: UIBarButtonItem = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(cancelAction(_:)))
    cancelBtn.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.fonts(.button), NSAttributedString.Key.foregroundColor: Gen.Colors.black.color], for: .normal)
    cancelBtn.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.fonts(.button), NSAttributedString.Key.foregroundColor: Gen.Colors.black.color], for: .highlighted)
    
    self.navigationController?.navigationBar.topItem?.leftBarButtonItems?.removeAll()
    self.navigationController?.navigationBar.topItem?.leftBarButtonItem = cancelBtn
    self.navigationController?.navigationBar.topItem?.rightBarButtonItems?.removeAll()
    self.navigationController?.navigationBar.topItem?.rightBarButtonItem = confirmBtn
    
    navigationItem.titleView = self.registPhotoSelectAlbumButtonView
  }
  
  private func setConfirmBtnColor(_ color: UIColor) {
    DispatchQueue.main.async { [weak self] in
      self?.confirmBtn?.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.fonts(.button), NSAttributedString.Key.foregroundColor: color], for: .normal)
      self?.confirmBtn?.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.fonts(.button), NSAttributedString.Key.foregroundColor: color], for: .highlighted)
    }
  }
  
  private func setConfirmBtnTitle(_ title: String) {
    DispatchQueue.main.async { [weak self] in
      self?.confirmBtn?.title = title
    }
  }
  
  @objc private func confirmAction(_ sender: UIButton) {
    self.reactor?.action.onNext(.confirm)
  }
  
  @objc private func cancelAction(_ sender: UIButton) {
    self.dismiss(animated: true, completion: nil)
  }
  
  private func showImageCoverTypeEditView(image: UIImage) {
    let cropViewController: CropViewController = CropViewController(croppingStyle: .default, image: image)
    cropViewController.delegate = self
    cropViewController.doneButtonTitle = "확인"
    cropViewController.doneButtonColor = Gen.Colors.white.color
    cropViewController.cancelButtonTitle = "취소"
    cropViewController.cancelButtonColor = Gen.Colors.white.color
    cropViewController.aspectRatioLockEnabled = true
    cropViewController.resetButtonHidden = true
    cropViewController.customAspectRatio = CGSize(width: 300, height: 300)
    cropViewController.aspectRatioPickerButtonHidden = true
    let emotionCoverImage = (self.reactor?.emotion ?? .fun).dimImage
    let emotionCoverImageView: UIImageView = UIImageView()
    emotionCoverImageView.contentMode = .scaleToFill
    emotionCoverImageView.image = emotionCoverImage
    cropViewController.cropView.insertSubview(emotionCoverImageView, belowSubview: cropViewController.cropView.gridOverlayView)
    emotionCoverImageView.snp.makeConstraints { (make) in
      let offset: CGFloat = UIDevice.current.hasNotch ? 24 : 0
      make.centerY.equalTo(cropViewController.cropView.snp.centerY).offset(offset)
      make.leading.equalTo(cropViewController.cropView.snp.leading).offset(12)
      make.trailing.equalTo(cropViewController.cropView.snp.trailing).offset(-12)
      make.height.equalTo(UIScreen.main.bounds.width - 24)
    }
    self.present(cropViewController, animated: true, completion: nil)
  }
  
  private func showImageImageTypeEditView(image: UIImage) {
    let cropViewController: CropViewController = CropViewController(croppingStyle: .default, image: image)
    cropViewController.delegate = self
    cropViewController.doneButtonTitle = "확인"
    cropViewController.doneButtonColor = Gen.Colors.white.color
    cropViewController.cancelButtonTitle = "취소"
    cropViewController.cancelButtonColor = Gen.Colors.white.color
    cropViewController.aspectRatioLockEnabled = true
    cropViewController.resetButtonHidden = true
    cropViewController.customAspectRatio = CGSize(width: 300, height: 400)
    cropViewController.aspectRatioPickerButtonHidden = true
    self.present(cropViewController, animated: true, completion: nil)
  }
  
  private static func fetchAlbumList() -> [AlbumModel] {
    var album: [AlbumModel] = [AlbumModel]()
    
    let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: PHFetchOptions())
    album.append(.init(
      identity: UUID(),
      name: "최근 항목",
      count: fetchResult.count,
      type: .all(thumbnail: fetchResult.lastObject)
    ))
    
    let options = PHFetchOptions()
    let userAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: options)
    
    userAlbums.enumerateObjects { (collectionObj, count: Int, stop: UnsafeMutablePointer) in
      let fetchOptions = PHFetchOptions()
      fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
      fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
      
      let newAlbum = AlbumModel(
        identity: UUID(),
        name: collectionObj.localizedTitle ?? "",
        count: collectionObj.estimatedAssetCount,
        type: .album(collectionObj)
      )
      album.append(newAlbum)
    }
    
    return album
  }
  
  private func fetchAllPhotoAssets() -> PHFetchResult<PHAsset> {
    let allPhotosOptions: PHFetchOptions = PHFetchOptions()
    let requestOptions: PHImageRequestOptions = PHImageRequestOptions()
    allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
    requestOptions.isSynchronous = true
    return PHAsset.fetchAssets(with: PHAssetMediaType.image, options: allPhotosOptions)
  }
  
  // MARK: internal function
  
}

extension RegistPhotoViewController: HWPhotoListFromAlbumViewDelegate {
  func changeFocusImg(focusIndex: Int) {
    
  }
  
  func selectedImgsFromAlbum(selectedImg: [PHAsset: PhotoFromAlbumModel], focusIndexAsset: PHAsset) {
    self.reactor?.action.onNext(.setOriginPhotoInfo(selectedImg))
    if selectedImg.count == 0 {
      self.setConfirmBtnTitle("선택")
      self.setConfirmBtnColor(Gen.Colors.gray04.color)
    } else {
      self.setConfirmBtnTitle("선택(\(selectedImg.count))")
      self.setConfirmBtnColor(Gen.Colors.black.color)
    }
    self.reactor?.action.onNext(.setImageInfos(selectedImg))
    self.reactor?.action.onNext(.setThumbnailImage(focusIndexAsset))
  }
}

extension RegistPhotoViewController: CropViewControllerDelegate {
  func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
    DispatchQueue.main.async { [weak self] in
      cropViewController.dismiss(animated: true, completion: { [weak self] in
        self?.reactor?.action.onNext(.setCropedImage(image))
      })
    }
  }
}

extension RegistPhotoViewController: AlbumSelectorViewControllerDelegate {
  
  func didSelectedAlbum(_ viewController: UIViewController, model: AlbumModel) {
    switch model.type {
    case .album(let collection):
      self.albumView?.setFetchAsset(fetchResult: PHAsset.fetchAssets(in: collection, options: nil))
    case .all:
      self.albumView?.setFetchAsset(fetchResult: self.fetchAllPhotoAssets())
    }
    self.registPhotoSelectAlbumButtonView.setTitle(model.name)
    self.reactor?.action.onNext(.clearSelectedImage)
    self.setConfirmBtnTitle("선택")
    self.setConfirmBtnColor(Gen.Colors.gray04.color)
  }
  
}

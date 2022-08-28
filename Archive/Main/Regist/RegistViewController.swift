//
//  RegistViewController.swift
//  Archive
//
//  Created by Aaron Hanwe LEE on 2022/08/11.
//

import UIKit
import Then
import SnapKit
import RxCocoa
import RxSwift
import ReactorKit
import CropViewController

class RegistViewController: UIViewController, View {
    
    // MARK: UI Property
    
    private let mainBackgroundView = UIView().then {
        $0.backgroundColor = Gen.Colors.white.color
    }
    
    private lazy var mainContentsView = HWFlipView(foregroundView: self.foregroundView, behindView: self.behindeView).then {
        $0.backgroundColor = .clear
    }
    
    // foregroundView
    
    private let foregroundView = UIView().then {
        $0.backgroundColor = Gen.Colors.white.color
    }
    
    private let foregroundScrollView = UIScrollView().then {
        $0.backgroundColor = .clear
    }
    
    private let foregroundContentsView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private lazy var topGradationView = UIImageView().then {
        $0.backgroundColor = .clear
        $0.image = Gen.Images.navigationGradation.image
    }
    
    private let foregroundBottomContentsView = RegistForegroundBottomView().then {
        $0.backgroundColor = .clear
    }
    
    private let foregroundTopContentsView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private let leftTriImgView = UIImageView().then {
        $0.image = Gen.Images.triLeft.image
    }
    
    private let rightTriImgView = UIImageView().then {
        $0.image = Gen.Images.triRight.image
    }
    
    private let emotionSelectView = RegistEmotionSelectTopView().then {
        $0.backgroundColor = .clear
    }
    
    private let foregroundTopStep1View = ForegroundStep1TopView().then {
        $0.backgroundColor = .clear
    }
    
    private lazy var foregroundStep2TopView = ForegroundStep2TopView(reactor: self.reactor ?? RegistReactor()).then {
        $0.backgroundColor = .clear
    }
    
    private let emotionSelectViewController = RegistEmotionSelectViewController(emotion: .pleasant).then {
        $0.modalPresentationStyle = .overFullScreen
    }
    
    private let pageControl = UIPageControl().then {
        $0.backgroundColor = .clear
        $0.pageIndicatorTintColor = Gen.Colors.gray03.color
        $0.currentPageIndicatorTintColor = Gen.Colors.black.color
        $0.isUserInteractionEnabled = false
    }
    
    private let contentsBottomView = RegistContentsBottomView().then {
        $0.backgroundColor = Gen.Colors.white.color
    }
    
    // behindeView
    
    private lazy var behindeView = RegistBehindView(navigationHeight: self.navigationController?.navigationBar.bounds.height ?? 0, reactor: self.reactor).then {
        $0.backgroundColor = Gen.Colors.white.color
    }
    
    // MARK: private property
    
    private var currentEditImageIndex: Int = 0
    private static var isFirst: Bool = true
    private var isKeyboardShown: Bool = false
    
    private var confirmForegroundBtn: UIBarButtonItem?
    private var confirmBackgroundBtn: UIBarButtonItem?
    
    // MARK: internal property
    
    var disposeBag: DisposeBag = DisposeBag()
    
    // MARK: life cycle
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init(reactor: RegistReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    override func loadView() {
        super.loadView()
        
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.navigationBar.tintColor = .white
        
        self.view.addSubview(self.mainBackgroundView)
        self.mainBackgroundView.snp.makeConstraints {
            $0.edges.equalTo(self.view)
        }
        
        let safeGuide = self.view.safeAreaLayoutGuide
        
        self.view.addSubview(self.mainContentsView)
        self.mainContentsView.snp.makeConstraints {
            $0.leading.trailing.equalTo(safeGuide)
            $0.bottom.equalTo(safeGuide)
            $0.top.equalTo(self.view)
        }
        
        self.foregroundView.addSubview(self.foregroundScrollView)
        self.foregroundScrollView.snp.makeConstraints {
            $0.edges.equalTo(self.foregroundView)
        }
        
        self.foregroundScrollView.addSubview(self.foregroundContentsView)
        self.foregroundContentsView.snp.makeConstraints {
            $0.edges.equalTo(self.foregroundScrollView).priority(750)
            $0.width.equalTo(self.foregroundScrollView).priority(1000)
        }
        
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        let statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        self.foregroundView.addSubview(self.topGradationView)
        self.topGradationView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(self.foregroundView)
            $0.height.equalTo(statusBarHeight + (self.navigationController?.navigationBar.bounds.height ?? 0))
        }
        
        self.foregroundContentsView.addSubview(self.foregroundBottomContentsView)
        self.foregroundBottomContentsView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalTo(self.foregroundContentsView)
            $0.height.equalTo(170)
        }
        
        self.foregroundContentsView.addSubview(self.foregroundTopContentsView)
        self.foregroundTopContentsView.snp.makeConstraints {
            $0.leading.trailing.top.equalTo(self.foregroundContentsView)
            $0.height.equalTo(UIScreen.main.bounds.width * 1.621333333)
            $0.bottom.equalTo(self.foregroundBottomContentsView.snp.top)
        }
        
        self.foregroundContentsView.addSubview(self.leftTriImgView)
        self.leftTriImgView.snp.makeConstraints {
            $0.width.height.equalTo(44)
            $0.leading.equalTo(self.foregroundTopContentsView)
            $0.bottom.equalTo(self.foregroundTopContentsView).offset(22)
        }
        
        self.foregroundContentsView.addSubview(self.rightTriImgView)
        self.rightTriImgView.snp.makeConstraints {
            $0.width.height.equalTo(44)
            $0.trailing.equalTo(self.foregroundTopContentsView)
            $0.bottom.equalTo(self.foregroundTopContentsView).offset(22)
        }
        
        self.foregroundContentsView.addSubview(self.emotionSelectView)
        self.emotionSelectView.snp.makeConstraints {
            $0.top.equalTo(safeGuide.snp.top).offset(32)
            $0.centerX.equalTo(foregroundContentsView)
        }
        
        self.foregroundTopContentsView.addSubview(self.foregroundTopStep1View)
        self.foregroundTopStep1View.snp.makeConstraints {
            $0.edges.equalTo(self.foregroundTopContentsView)
        }
        
        self.foregroundTopContentsView.addSubview(self.foregroundStep2TopView)
        self.foregroundStep2TopView.snp.makeConstraints {
            $0.edges.equalTo(self.foregroundTopContentsView)
        }
        self.foregroundStep2TopView.topBarHeight = self.topbarHeight
        self.foregroundStep2TopView.isHidden = true
        self.foregroundStep2TopView.bind()
        
        self.foregroundBottomContentsView.addSubview(self.contentsBottomView)
        self.contentsBottomView.snp.makeConstraints {
            $0.edges.equalTo(self.foregroundBottomContentsView)
        }
        self.contentsBottomView.isHidden = true
        
        self.foregroundContentsView.addSubview(self.pageControl)
        self.pageControl.snp.makeConstraints {
            $0.centerX.equalTo(self.foregroundContentsView)
            $0.width.equalTo(165)
            $0.height.equalTo(32)
            $0.bottom.equalTo(self.foregroundContentsView)
        }
        
        self.pageControl.isHidden = true
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeNavigationItems()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification(_:)), name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotification(_:)), name: UIWindow.keyboardWillHideNotification, object: nil)
        makeConfirmBtn()
        setForegroundConfirmBtn()
    }
    
    deinit {
        print("\(self) deinit")
    }
    
    func bind(reactor: RegistReactor) {
        self.foregroundBottomContentsView.rx.clickedRegistTitle
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] in
                self?.mainContentsView.flip(complition: { [weak self] in
                    if self?.mainContentsView.currentFlipType == .behind {
                        self?.behindeView.selectArchiveNameTextField()
                    }
                })
            })
            .disposed(by: self.disposeBag)
        
        self.emotionSelectView.rx.clickedSelectEmotion
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] in
                self?.navigationController?
                    .present(self?.emotionSelectViewController ?? UIViewController(),
                             animated: false,
                             completion: { [weak self] in
                        self?.foregroundContentsView.isHidden = true
                        self?.emotionSelectViewController.fadeInAnimation()
                    })
            })
            .disposed(by: self.disposeBag)
        
        self.emotionSelectViewController.rx.selectedEmotion
            .asDriver(onErrorJustReturn: .pleasant)
            .drive(onNext: { [weak self] selectedEmotion in
                self?.foregroundContentsView.isHidden = false
                self?.emotionSelectView.emotion = selectedEmotion
                self?.foregroundTopStep1View.isHidden = true
                reactor.action.onNext(.setEmotion(selectedEmotion))
                self?.foregroundStep2TopView.isHidden = false
                self?.foregroundStep2TopView.emotion = selectedEmotion
            })
            .disposed(by: self.disposeBag)
        
        self.foregroundStep2TopView.rx.selectImage
            .observe(on: ConcurrentDispatchQueueScheduler(queue: .global()))
            .subscribe(onNext: {
                reactor.action.onNext(.requestPhotoAccessAuth)
            })
            .disposed(by: self.disposeBag)
        
        reactor.photoAccessAuthSuccess
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] in
                let vc = RegistPhotoViewController(reactor: RegistPhotoReactor(emotion: self?.reactor?.currentState.emotion ?? .pleasant))
                vc.delegate = self
                let navi = UINavigationController(rootViewController: vc)
                navi.modalPresentationStyle = .fullScreen
                self?.present(navi, animated: true)
            })
            .disposed(by: self.disposeBag)
        
        self.foregroundStep2TopView.rx.editImage
            .asDriver(onErrorJustReturn: IndexPath(row: 0, section: 0))
            .drive(onNext: { [weak self] indexPath in
                guard let imageInfo = self?.reactor?.currentState.imageInfo.images[indexPath.row] else { return }
                self?.currentEditImageIndex = indexPath.row
                self?.showImageEditView(image: imageInfo.image)
            })
            .disposed(by: self.disposeBag)
        
        self.foregroundStep2TopView.rx.didShownIndex
            .asDriver(onErrorJustReturn: 0)
            .drive(onNext: { [weak self] index in
                if index == 0 {
                    self?.emotionSelectView.isHidden = false
                } else {
                    self?.emotionSelectView.isHidden = true
                }
            })
            .disposed(by: self.disposeBag)
        
        self.foregroundStep2TopView.rx.didShownIndex
            .asDriver(onErrorJustReturn: 0)
            .drive(onNext: { [weak self] index in
                if (index == reactor.currentState.imageInfo.images.count) && reactor.currentState.imageInfo.images.count != 0 {
                    self?.foregroundBottomContentsView.isHidden = true
                } else {
                    self?.foregroundBottomContentsView.isHidden = false
                }
            })
            .disposed(by: self.disposeBag)
        
        self.foregroundStep2TopView.rx.didShownIndex
            .asDriver(onErrorJustReturn: 0)
            .drive(onNext: { [weak self] index in
                if (index != reactor.currentState.imageInfo.images.count) &&
                    reactor.currentState.imageInfo.images.count != 0 &&
                    index != 0 {
                    self?.contentsBottomView.isHidden = false
                } else {
                    self?.contentsBottomView.isHidden = true
                }
            })
            .disposed(by: self.disposeBag)
        
        self.foregroundStep2TopView.rx.didShownIndex
            .asDriver(onErrorJustReturn: 0)
            .drive(onNext: { [weak self] index in
                if index >= 1 {
                    if let contents = reactor.currentState.photoContents[index] {
                        self?.contentsBottomView.setContents(contents)
                    } else {
                        self?.contentsBottomView.setContents("")
                    }
                }
            })
            .disposed(by: self.disposeBag)
        
        self.foregroundStep2TopView.rx.didShownIndex
            .asDriver(onErrorJustReturn: 0)
            .drive(onNext: { [weak self] index in
                self?.pageControl.currentPage = index
                self?.contentsBottomView.index = index
            })
            .disposed(by: self.disposeBag)
        
        reactor.state
            .map { $0.imageInfo.images }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: nil)
            .compactMap { $0 }
            .drive(onNext: { [weak self] images in
                if images.count != 0 {
                    self?.pageControl.isHidden = false
                    self?.pageControl.numberOfPages = images.count + 1
                } else {
                    self?.pageControl.isHidden = true
                }
            })
            .disposed(by: self.disposeBag)
        
        reactor.state
            .map { $0.imageInfo }
            .distinctUntilChanged()
            .compactMap { $0 }
            .observe(on: ConcurrentDispatchQueueScheduler(queue: .global()))
            .subscribe(onNext: { info in
                if info.isMoveFirstIndex {
                    reactor.action.onNext(.clearPhotoContents)
                }
            })
            .disposed(by: self.disposeBag)
        
        self.contentsBottomView.rx.confirmed
            .asDriver(onErrorJustReturn: ("", 1))
            .drive(onNext: { [weak self] text, index in
                self?.view.endEditing(true)
                print("text: \(text) index: \(index)")
                reactor.action.onNext(.setPhotoContents(index: index, contents: text))
            })
            .disposed(by: self.disposeBag)
        
        reactor.state
            .map { $0.emotion }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: .pleasant)
            .compactMap { $0 }
            .drive(onNext: { [weak self] emotion in
                self?.behindeView.emotion = emotion
            })
            .disposed(by: self.disposeBag)
        
        self.mainContentsView.rx.didFliped
            .asDriver(onErrorJustReturn: .foreground)
            .drive(onNext: { [weak self] type in
                switch type {
                case .foreground:
                    self?.setForegroundConfirmBtn()
                case .behind:
                    self?.setBackgroundConfirmBtn()
                }
            })
            .disposed(by: self.disposeBag)
        
        reactor.state
            .map { $0.archiveName }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: "")
            .compactMap { $0 }
            .drive(onNext: { [weak self] name in
                self?.foregroundBottomContentsView.setRegistTitle(name)
            })
            .disposed(by: self.disposeBag)
        
        reactor.state
            .map { $0.isBehineViewConfirmIsEnable }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: true)
            .compactMap { $0 }
            .drive(onNext: { [weak self] isEnable in
                self?.confirmBackgroundBtn?.isEnabled = isEnable
            })
            .disposed(by: self.disposeBag)
        
        reactor.state
            .map { $0.isForegroundViewConfirmIsEnable }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: true)
            .compactMap { $0 }
            .drive(onNext: { [weak self] isEnable in
                self?.confirmForegroundBtn?.isEnabled = isEnable
            })
            .disposed(by: self.disposeBag)
        
        self.behindeView.rx.requestFlip
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] in
                self?.mainContentsView.flip(complition: nil)
            })
            .disposed(by: self.disposeBag)
        
        reactor.moveToConfig
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] in
                CommonAlertView.shared.show(message: "티켓 기록 사진을 선택하려면 사진 라이브러리 접근권한이 필요합니다.", subMessage: nil, btnText: "확인", hapticType: .warning, confirmHandler: {
                    Util.moveToSetting()
                    CommonAlertView.shared.hide(nil)
                })
            })
            .disposed(by: self.disposeBag)

    }
    
    // MARK: private func
    
    private func makeNavigationItems() {
        let closeImage = Gen.Images.closeWhite.image
        closeImage.withRenderingMode(.alwaysTemplate)
        let backBarButtonItem = UIBarButtonItem(image: closeImage, style: .plain, target: self, action: #selector(closeButtonClicked(_:)))
        backBarButtonItem.tintColor = Gen.Colors.white.color
        self.navigationItem.leftBarButtonItem = backBarButtonItem
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: Gen.Colors.white.color]
        self.title = "전시기록"
    }
    
    @objc private func closeButtonClicked(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    private func showImageEditView(image: UIImage) {
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
        self.present(cropViewController, animated: true, completion: nil)
    }
    
    @objc private func keyboardWillShowNotification(_ notification: Notification) {
        if !isKeyboardShown { // 키보드가 안올라와있을 때만 실행...
            self.isKeyboardShown = true
            if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                let safeGuide = self.view.safeAreaLayoutGuide
                let paddding = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.safeAreaInsets.bottom ?? 0
                if RegistViewController.isFirst { // 오토레이아웃 버그 임시방편 수정 ㅠㅠ
                    RegistViewController.isFirst = false
                    self.mainContentsView.snp.updateConstraints {
                        $0.bottom.equalTo(safeGuide).offset(-(keyboardSize.height - paddding))
                        $0.top.equalTo(self.view).offset(-self.topbarHeight)
                    }
                } else {
                    self.mainContentsView.snp.updateConstraints {
                        $0.bottom.equalTo(safeGuide).offset(-(keyboardSize.height + self.topbarHeight + 23))
                        $0.top.equalTo(self.view).offset(-self.topbarHeight)
                    }
                }

                self.foregroundScrollView.setContentOffset(CGPoint(x: 0, y: keyboardSize.height - paddding), animated: false)
                UIView.animate(withDuration: 1.0, animations: { [weak self] in
                    self?.view.layoutIfNeeded()
                })
            }
        }
    }
    
    @objc private func keyboardWillHideNotification(_ notification: Notification) {
        self.isKeyboardShown = false
        let safeGuide = self.view.safeAreaLayoutGuide
        self.mainContentsView.snp.updateConstraints {
            $0.bottom.equalTo(safeGuide)
            $0.top.equalTo(self.view)
        }
        UIView.animate(withDuration: 1.0, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        })
    }
    
    private func makeConfirmBtn() {
        self.confirmForegroundBtn = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(confirmAction(_:)))
        self.confirmForegroundBtn?.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.fonts(.button2), NSAttributedString.Key.foregroundColor: Gen.Colors.white.color], for: .normal)
        self.confirmForegroundBtn?.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.fonts(.button2), NSAttributedString.Key.foregroundColor: Gen.Colors.white.color], for: .highlighted)
        self.confirmForegroundBtn?.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.fonts(.button2), NSAttributedString.Key.foregroundColor: Gen.Colors.gray05.color], for: .disabled)
        self.confirmForegroundBtn?.isEnabled = false
        
        self.confirmBackgroundBtn = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(confirmAction(_:)))
        self.confirmBackgroundBtn?.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.fonts(.button2), NSAttributedString.Key.foregroundColor: Gen.Colors.white.color], for: .normal)
        self.confirmBackgroundBtn?.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.fonts(.button2), NSAttributedString.Key.foregroundColor: Gen.Colors.white.color], for: .highlighted)
        self.confirmBackgroundBtn?.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.fonts(.button2), NSAttributedString.Key.foregroundColor: Gen.Colors.gray05.color], for: .disabled)
        self.confirmBackgroundBtn?.isEnabled = false
    }
    
    private func setForegroundConfirmBtn() {
        self.navigationController?.navigationBar.topItem?.rightBarButtonItems?.removeAll()
        self.navigationController?.navigationBar.topItem?.rightBarButtonItem = confirmForegroundBtn
    }
    
    private func setBackgroundConfirmBtn() {
        self.navigationController?.navigationBar.topItem?.rightBarButtonItems?.removeAll()
        self.navigationController?.navigationBar.topItem?.rightBarButtonItem = confirmBackgroundBtn
    }
    
    @objc private func confirmAction(_ sender: UIButton) {
        if self.mainContentsView.currentFlipType == .foreground {
            self.reactor?.action.onNext(.regist)
        } else {
            self.mainContentsView.flip(complition: { [weak self] in
                self?.view.endEditing(true)
            })
        }
    }
    
    // MARK: internal func
    
    
}

extension RegistViewController: RegistPhotoViewControllerDelegate {
    func selectedImages(images: [RegistImageInfo]) {
        DispatchQueue.main.async { [weak self] in
            self?.foregroundStep2TopView.hideEmptyView()
            self?.reactor?.action.onNext(.setImageInfo(RegistImagesInfo(images: images, isMoveFirstIndex: true)))
        }
    }
}

extension RegistViewController: CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        DispatchQueue.main.async { [weak self] in
            cropViewController.dismiss(animated: true, completion: { [weak self] in
                self?.reactor?.action.onNext(.cropedImage(cropedimage: image, index: self?.currentEditImageIndex ?? 0))
            })
        }
    }
}

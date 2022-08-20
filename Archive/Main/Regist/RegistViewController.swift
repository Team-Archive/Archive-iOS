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
    
    // behindeView
    
    private let behindeView = UIView().then {
//        $0.backgroundColor = Gen.Colors.white.color
        $0.backgroundColor = .gray
    }
    
    // MARK: private property
    
    private var currentEditImageIndex: Int = 0
    
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
        
        self.view.addSubview(self.mainBackgroundView)
        self.mainBackgroundView.snp.makeConstraints {
            $0.edges.equalTo(self.view)
        }
        
        let safeGuide = self.view.safeAreaLayoutGuide
        
        self.view.addSubview(self.mainContentsView)
        self.mainContentsView.snp.makeConstraints {
            $0.bottom.leading.trailing.equalTo(safeGuide)
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
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeNavigationItems()
    }
    
    deinit {
        print("\(self) deinit")
    }
    
    func bind(reactor: RegistReactor) {
        self.foregroundBottomContentsView.rx.clickedRegistTitle
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] in
                self?.mainContentsView.flip(complition: nil)
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
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] in
                let vc = RegistPhotoViewController(reactor: RegistPhotoReactor(emotion: self?.reactor?.currentState.emotion ?? .pleasant))
                let navi = UINavigationController(rootViewController: vc)
                navi.modalPresentationStyle = .fullScreen
                self?.present(navi, animated: true)
                guard let strongSelf = self else { return }
                vc.rx.selectedImages.subscribe(onNext: { [weak self] images in
                    self?.foregroundStep2TopView.hideEmptyView()
                    self?.reactor?.action.onNext(.setImages(images))
                })
                .disposed(by: strongSelf.disposeBag)
            })
            .disposed(by: self.disposeBag)
        
        self.foregroundStep2TopView.rx.editImage
            .asDriver(onErrorJustReturn: IndexPath(row: 0, section: 0))
            .drive(onNext: { [weak self] indexPath in
                guard let image = self?.reactor?.currentState.images[indexPath.row] else { return }
                self?.currentEditImageIndex = indexPath.row
                self?.showImageEditView(image: image)
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
    
    // MARK: internal func
    
    
}

extension RegistViewController: CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        DispatchQueue.main.async { [weak self] in
            cropViewController.dismiss(animated: true, completion: { [weak self] in
                guard var images = self?.reactor?.currentState.images else { return }
                images.insert(image, at: self?.currentEditImageIndex ?? 0)
                images.remove(at: (self?.currentEditImageIndex ?? 0) + 1)
                self?.reactor?.action.onNext(.setImages(images))
            })
        }
    }
}

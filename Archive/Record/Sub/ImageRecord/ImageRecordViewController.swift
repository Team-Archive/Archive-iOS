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

protocol ImageRecordViewControllerProtocol: AnyObject {
    func setUICurrentEmotion(_ emotion: Emotion)
    func setRecordTitle(_ title: String)
    func hideTopView()
    func showTopView()
    
    var delegate: ImageRecordViewControllerDelegate? { get set }
}

protocol ImageRecordViewControllerDelegate: AnyObject {
    func clickedEmotionSelectArea()
    func clickedPhotoSeleteArea()
    func clickedContentsArea()
}

class ImageRecordViewController: UIViewController, StoryboardView, ImageRecordViewControllerProtocol { // 뷰컨만 있어도 될듯
    
    // MARK: IBOutlet
    @IBOutlet weak var mainBackgroundView: UIView!
    @IBOutlet weak var scrollContainerView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mainContainerView: UIView!
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
    
    // MARK: private property
    
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
    
    func bind(reactor: ImageRecordReactor) {
        self.addPhotoBtn.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.delegate?.clickedPhotoSeleteArea()
            })
            .disposed(by: self.disposeBag)
        
        self.emotionSelectBtn.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.delegate?.clickedEmotionSelectArea()
            })
            .disposed(by: self.disposeBag)
        
        self.bottomBtn.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.delegate?.clickedContentsArea()
            })
            .disposed(by: self.disposeBag)
        
        reactor.state.map { $0.images }
        .asDriver(onErrorJustReturn: [])
        .drive(onNext: { [weak self] images in
            if images.count == 0 {
                self?.defaultImageContainerView.isHidden = false
            } else {
                self?.defaultImageContainerView.isHidden = true
            }
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
        self.imagesCollectionView.isHidden = true
    }
    
    // MARK: internal function
    
    func setRecordTitle(_ title: String) {
        DispatchQueue.main.async { [weak self] in
            self?.doWriteLabel.text = title
            self?.doWriteLabel.textColor = Gen.Colors.black.color
        }
    }
    
    func setUICurrentEmotion(_ emotion: Emotion) {
        self.addPhotoImgView.isHidden = false
        self.addPhotoBtn.isHidden = false
        switch emotion {
        case .fun:
            self.coverImageView.image = Gen.Images.coverFun.image
            self.topContainerView.backgroundColor = Gen.Colors.funYellow.color
            self.miniEmotionImageView.image = Gen.Images.typeFunMini.image
            self.emotionLabel.text = "재미있는"
        case .impressive:
            self.coverImageView.image = Gen.Images.coverImpressive.image
            self.topContainerView.backgroundColor = Gen.Colors.impressiveGreen.color
            self.miniEmotionImageView.image = Gen.Images.typeImpressiveMini.image
            self.emotionLabel.text = "인상적인"
        case .pleasant:
            self.coverImageView.image = Gen.Images.coverPleasant.image
            self.topContainerView.backgroundColor = Gen.Colors.pleasantRed.color
            self.miniEmotionImageView.image = Gen.Images.typePleasantMini.image
            self.emotionLabel.text = "기분좋은"
        case .splendid:
            self.coverImageView.image = Gen.Images.coverSplendid.image
            self.topContainerView.backgroundColor = Gen.Colors.splendidBlue.color
            self.miniEmotionImageView.image = Gen.Images.typeSplendidMini.image
            self.emotionLabel.text = "아름다운"
        case .wonderful:
            self.coverImageView.image = Gen.Images.coverWonderful.image
            self.topContainerView.backgroundColor = Gen.Colors.wonderfulPurple.color
            self.miniEmotionImageView.image = Gen.Images.typeWonderfulMini.image
            self.emotionLabel.text = "경이로운"
        }
    }
    
    func hideTopView() {
        self.topContainerView.isHidden = true
    }
    
    func showTopView() {
        self.topContainerView.isHidden = false
    }
    
    // MARK: action
    
    

    
    
    
}

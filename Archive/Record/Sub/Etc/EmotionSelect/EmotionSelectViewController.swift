//
//  EmotionSelectViewController.swift
//  Archive
//
//  Created by hanwe lee on 2021/10/25.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa
import SnapKit
import Then

class EmotionSelectViewController: UIViewController, View {
    
//     MARK: IBOutlet
//    @IBOutlet weak var baseContainerView: UIView!
//    @IBOutlet weak var mainBackgroundView: UIView!
//    @IBOutlet weak var bottomPaddingView: UIView!
//    @IBOutlet weak var mainContentsView: UIView!
//    @IBOutlet weak var bottomView: UIView!
//    @IBOutlet weak var titleLabel: UILabel!
//    @IBOutlet weak var completeBtn: UIButton!
//    @IBOutlet weak var contentsLabel: UILabel!
//    @IBOutlet weak var preImageView: UIImageView!
//
//    @IBOutlet weak var pleasantBtn: UIButton!
//    @IBOutlet weak var funBtn: UIButton!
//    @IBOutlet weak var splendidBtn: UIButton!
//    @IBOutlet weak var wonderfulBtn: UIButton!
//    @IBOutlet weak var impressiveBtn: UIButton!
//
//    @IBOutlet weak var pleasantImageView: UIImageView!
//    @IBOutlet weak var funImageView: UIImageView!
//    @IBOutlet weak var splendidImageView: UIImageView!
//    @IBOutlet weak var wonderfulImageView: UIImageView!
//    @IBOutlet weak var impressiveImageView: UIImageView!
//
//    @IBOutlet weak var pleasantLabel: UILabel!
//    @IBOutlet weak var funLabel: UILabel!
//    @IBOutlet weak var splendidLabel: UILabel!
//    @IBOutlet weak var wonderfulLabel: UILabel!
//    @IBOutlet weak var impressiveLabel: UILabel!
//
//    @IBOutlet weak var helpLabel: UILabel!
    
    // MARK: UIProperty
    
    private let mainBackgroundView = UIView().then {
        $0.backgroundColor = Gen.Colors.dim.color
    }
    
    private let mainContentsView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private let bottomView = TopConerRadiusView().then {
        $0.backgroundColor = Gen.Colors.white.color
    }
    
    private let bottomViewTitleLabel = UILabel().then {
        $0.font = .fonts(.header3)
        $0.textColor = Gen.Colors.gray01.color
        $0.text = "전시가 어땠나요?"
    }
    
    private let bottomViewSubtitleLabel = UILabel().then {
        $0.font = .fonts(.body)
        $0.textColor = Gen.Colors.gray02.color
        $0.text = "선택한 감정으로 티켓커버가 변경됩니다."
    }
    
    private let confirmBtn = UIButton().then {
        $0.setTitleAllState("완료")
        $0.setTitleColor(Gen.Colors.black.color, for: .normal)
        $0.titleLabel?.font = .fonts(.button)
    }
    
    private let selectEmotionView = ArchiveSelectEmotionView().then {
        $0.backgroundColor = .clear
    }
    
    private let helpEmotionImageContainerView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private let emotionSampleImageView = UIImageView().then {
        $0.backgroundColor = .clear
        $0.image = Emotion.pleasant.preImage
    }
    
    private let emotionSampleLabel = UILabel().then {
        $0.font = .fonts(.subTitle)
        $0.textColor = Gen.Colors.gray03.color
        $0.text = "이 영역에\n이미지가 표시됩니다."
        $0.textAlignment = .center
        $0.numberOfLines = 2
    }
    
    // MARK: private property
    
    // MARK: internal property
    var disposeBag: DisposeBag = DisposeBag()
    
    // MARK: lifeCycle
    
    init(reactor: EmotionSelectReactor) {
        super.init(nibName: nil, bundle: nil)
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
    }
    
    override func loadView() {
        super.loadView()
        setup()
    }
    
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
        
        let bottomNotchHeight = UIDevice.current.hasNotch ? 35 : 0
        self.mainContentsView.addSubview(self.bottomView)
        self.bottomView.snp.makeConstraints {
            $0.bottom.equalTo(self.mainContentsView.snp.bottom).offset(bottomNotchHeight)
            $0.leading.equalTo(self.mainContentsView.snp.leading)
            $0.trailing.equalTo(self.mainContentsView.snp.trailing)
            $0.height.equalTo(205 + bottomNotchHeight)
        }
        
        self.bottomView.addSubview(self.bottomViewTitleLabel)
        self.bottomViewTitleLabel.snp.makeConstraints {
            $0.top.equalTo(self.bottomView.snp.top).offset(34)
            $0.leading.equalTo(self.bottomView.snp.leading).offset(32)
            $0.trailing.equalTo(self.bottomView.snp.trailing).offset(-32)
        }
        
        self.bottomView.addSubview(self.confirmBtn)
        self.confirmBtn.snp.makeConstraints {
            $0.trailing.equalTo(self.bottomView.snp.trailing).offset(-38)
            $0.centerY.equalTo(self.bottomViewTitleLabel.snp.centerY)
        }
        
        self.bottomView.addSubview(self.bottomViewSubtitleLabel)
        self.bottomViewSubtitleLabel.snp.makeConstraints {
            $0.top.equalTo(self.bottomViewTitleLabel.snp.bottom).offset(8)
            $0.leading.equalTo(self.bottomViewTitleLabel.snp.leading)
            $0.trailing.equalTo(self.bottomViewTitleLabel.snp.trailing)
        }
        
        self.bottomView.addSubview(self.selectEmotionView)
        self.selectEmotionView.snp.makeConstraints {
            $0.top.equalTo(self.bottomViewSubtitleLabel.snp.bottom).offset(36)
            $0.leading.equalTo(self.bottomView.snp.leading)
            $0.trailing.equalTo(self.bottomView.snp.trailing)
            $0.height.equalTo(70)
        }
        
        self.mainContentsView.addSubview(self.helpEmotionImageContainerView)
        self.helpEmotionImageContainerView.snp.makeConstraints {
            $0.leading.equalTo(self.mainContentsView.snp.leading).offset(32)
            $0.trailing.equalTo(self.mainContentsView.snp.trailing).offset(-32)
            $0.bottom.equalTo(self.bottomView.snp.top).offset(-34)
            $0.height.equalTo(self.helpEmotionImageContainerView.snp.width)
        }
        
        self.helpEmotionImageContainerView.addSubview(self.emotionSampleImageView)
        self.emotionSampleImageView.snp.makeConstraints {
            $0.edges.equalTo(self.helpEmotionImageContainerView.snp.edges)
        }
        
        self.helpEmotionImageContainerView.addSubview(self.emotionSampleLabel)
        self.emotionSampleLabel.snp.makeConstraints {
            $0.centerY.equalTo(self.helpEmotionImageContainerView.snp.centerY)
            $0.leading.equalTo(self.helpEmotionImageContainerView.snp.leading)
            $0.trailing.equalTo(self.helpEmotionImageContainerView.snp.trailing)
        }
    }
    
    func bind(reactor: EmotionSelectReactor) {
//        self.pleasantBtn.rx.tap
//            .map { Reactor.Action.select(.pleasant) }
//            .bind(to: reactor.action)
//            .disposed(by: self.disposeBag)
//
//        self.funBtn.rx.tap
//            .map { Reactor.Action.select(.fun) }
//            .bind(to: reactor.action)
//            .disposed(by: self.disposeBag)
//
//        self.splendidBtn.rx.tap
//            .map { Reactor.Action.select(.splendid) }
//            .bind(to: reactor.action)
//            .disposed(by: self.disposeBag)
//
//        self.wonderfulBtn.rx.tap
//            .map { Reactor.Action.select(.wonderful) }
//            .bind(to: reactor.action)
//            .disposed(by: self.disposeBag)
//
//        self.impressiveBtn.rx.tap
//            .map { Reactor.Action.select(.impressive) }
//            .bind(to: reactor.action)
//            .disposed(by: self.disposeBag)
//
//        reactor.state
//            .map { $0.currentEmotion }
//            .asDriver(onErrorJustReturn: .pleasant)
//            .drive(onNext: { [weak self] emotion in
//                self?.refreshUIForEmotion(emotion)
//            })
//            .disposed(by: self.disposeBag)
//
//        self.completeBtn.rx.tap
//            .map { Reactor.Action.completeEmotionEdit }
//            .bind(to: reactor.action )
//            .disposed(by: self.disposeBag)
    }
    
    // MARK: private function
    
    private func initUI() {
//        self.mainBackgroundView.backgroundColor = Gen.Colors.dim.color
//        self.mainContentsView.backgroundColor = .clear
//        self.bottomPaddingView.backgroundColor = Gen.Colors.white.color
//        self.bottomView.backgroundColor = Gen.Colors.white.color
//        self.titleLabel.font = .fonts(.header3)
//        self.titleLabel.textColor = Gen.Colors.gray01.color
//        self.titleLabel.text = "전시가 어땠나요?"
//
//        self.completeBtn.titleLabel?.font = .fonts(.button)
//        self.completeBtn.setTitle("완료", for: .normal)
//        self.completeBtn.setTitle("완료", for: .highlighted)
//
//        self.completeBtn.setTitleColor(Gen.Colors.black.color, for: .normal)
//        self.completeBtn.setTitleColor(Gen.Colors.black.color, for: .highlighted)
//
//        self.contentsLabel.font = .fonts(.body)
//        self.contentsLabel.textColor = Gen.Colors.gray02.color
//        self.contentsLabel.text = "선택한 감정으로 티켓커버가 변경됩니다."
//
//        self.pleasantLabel.font = .fonts(.body)
//        self.pleasantLabel.text = "기분좋은"
//        self.funLabel.font = .fonts(.body)
//        self.funLabel.text = "재미있는"
//        self.splendidLabel.font = .fonts(.body)
//        self.splendidLabel.text = "아름다운"
//        self.wonderfulLabel.font = .fonts(.body)
//        self.wonderfulLabel.text = "경이로운"
//        self.impressiveLabel.font = .fonts(.body)
//        self.impressiveLabel.text = "인상적인"
//
//        self.helpLabel.font = .fonts(.subTitle)
//        self.helpLabel.textColor = Gen.Colors.gray03.color
//        self.helpLabel.text = "이 영역에\n이미지가 표시됩니다."
    }
    
    private func refreshUIForEmotion(_ emotion: Emotion) {
//        self.pleasantImageView.image = Gen.Images.typePleasantNo.image
//        self.funImageView.image = Gen.Images.typeFunNo.image
//        self.splendidImageView.image = Gen.Images.typeSplendidNo.image
//        self.wonderfulImageView.image = Gen.Images.typeWonderfulNo.image
//        self.impressiveImageView.image = Gen.Images.typeImpressiveNo.image
//        self.pleasantLabel.textColor = Gen.Colors.gray03.color
//        self.funLabel.textColor = Gen.Colors.gray03.color
//        self.splendidLabel.textColor = Gen.Colors.gray03.color
//        self.wonderfulLabel.textColor = Gen.Colors.gray03.color
//        self.impressiveLabel.textColor = Gen.Colors.gray03.color
//        switch emotion { // TODO: 처리하기
//        case .fun:
//            self.funImageView.image = Gen.Images.typeFun.image
//            self.preImageView.image = Gen.Images.preFun.image
//            self.funLabel.textColor = Gen.Colors.black.color
//        case .impressive:
//            self.impressiveImageView.image = Gen.Images.typeImpressive.image
//            self.preImageView.image = Gen.Images.preImpressive.image
//            self.impressiveLabel.textColor = Gen.Colors.black.color
//        case .pleasant:
//            self.pleasantImageView.image = Gen.Images.typePleasant.image
//            self.preImageView.image = Gen.Images.prePleasant.image
//            self.pleasantLabel.textColor = Gen.Colors.black.color
//        case .splendid:
//            self.splendidImageView.image = Gen.Images.typeSplendid.image
//            self.preImageView.image = Gen.Images.preSplendid.image
//            self.splendidLabel.textColor = Gen.Colors.black.color
//        case .wonderful:
//            self.wonderfulImageView.image = Gen.Images.typeWonderful.image
//            self.preImageView.image = Gen.Images.preWonderful.image
//            self.wonderfulLabel.textColor = Gen.Colors.black.color
//        }
    }
    
    // MARK: internal function
    
    func fadeInAnimation() {
        self.view.fadeIn(duration: 0.25, completeHandler: nil)
    }

}

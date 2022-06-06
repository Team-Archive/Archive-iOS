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
        
        self.selectEmotionView.rx
            .selectedIndex
            .subscribe(onNext: { [weak self] index in
                if index == -1 { return }
                guard let emotion = Emotion.getEmotionFromIndex(index) else { return }
                reactor.action.onNext(.select(emotion))
            })
            .disposed(by: self.disposeBag)
        
        reactor.state
            .map { $0.currentEmotion }
            .asDriver(onErrorJustReturn: .pleasant)
            .drive(onNext: { [weak self] emotion in
                self?.emotionSampleImageView.image = emotion.preImage
            })
            .disposed(by: self.disposeBag)
        
        self.confirmBtn.rx.tap
            .map { Reactor.Action.completeEmotionEdit }
            .bind(to: reactor.action )
            .disposed(by: self.disposeBag)
    }
    
    // MARK: private function
    
    // MARK: internal function
    
    func fadeInAnimation() {
        self.view.fadeIn(duration: 0.25, completeHandler: nil)
    }

}

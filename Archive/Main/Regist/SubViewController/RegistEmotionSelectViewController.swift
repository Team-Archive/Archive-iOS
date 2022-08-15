//
//  RegistEmotionSelectViewController.swift
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

@objc protocol RegistEmotionSelectViewControllerDelegate: AnyObject {
    @objc optional func selectedEmotion(emotion: Emotion)
}

class RegistEmotionSelectViewController: UIViewController {
    
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
    
    private lazy var emotionSampleImageView = UIImageView().then {
        $0.backgroundColor = .clear
        $0.image = self.selectedEmotion.preImage
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
    
    let disposeBag: DisposeBag = DisposeBag()
    
    weak var delegate: RegistEmotionSelectViewControllerDelegate?
    private(set) var selectedEmotion: Emotion {
        didSet {
            let emotion = self.selectedEmotion
            DispatchQueue.main.async { [weak self] in
                self?.refreshUI(emotion: emotion)
            }
        }
    }
    
    // MARK: lifeCycle

    init(emotion: Emotion) {
        self.selectedEmotion = emotion
        super.init(nibName: nil, bundle: nil)
        self.view.alpha = 0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("\(self) deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.selectEmotionView.rx
            .selectedEmotion
            .subscribe(onNext: { [weak self] emotion in
                self?.selectedEmotion = emotion
            })
            .disposed(by: self.disposeBag)
        
        self.confirmBtn.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.delegate?.selectedEmotion?(emotion: self?.selectedEmotion ?? .pleasant)
                self?.view.alpha = 0
                self?.dismiss(animated: false)
            })
            .disposed(by: self.disposeBag)
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
    
    // MARK: private function
    
    private func refreshUI(emotion: Emotion) {
        self.emotionSampleImageView.image = emotion.preImage
    }
    
    // MARK: internal function
    
    func fadeInAnimation() {
        self.view.fadeIn(duration: 0.25, completeHandler: nil)
    }

}

class RegistEmotionSelectViewControllerDelegateProxy: DelegateProxy<RegistEmotionSelectViewController, RegistEmotionSelectViewControllerDelegate>, DelegateProxyType, RegistEmotionSelectViewControllerDelegate {
    
    
    static func currentDelegate(for object: RegistEmotionSelectViewController) -> RegistEmotionSelectViewControllerDelegate? {
        return object.delegate
    }
    
    static func setCurrentDelegate(_ delegate: RegistEmotionSelectViewControllerDelegate?, to object: RegistEmotionSelectViewController) {
        object.delegate = delegate
    }
    
    static func registerKnownImplementations() {
        self.register { (view) -> RegistEmotionSelectViewControllerDelegateProxy in
            RegistEmotionSelectViewControllerDelegateProxy(parentObject: view, delegateProxy: self)
        }
    }
}

extension Reactive where Base: RegistEmotionSelectViewController {
    var delegate: DelegateProxy<RegistEmotionSelectViewController, RegistEmotionSelectViewControllerDelegate> {
        return RegistEmotionSelectViewControllerDelegateProxy.proxy(for: self.base)
    }
    
    var selectedEmotion: Observable<Emotion> {
        return delegate.methodInvoked(#selector(RegistEmotionSelectViewControllerDelegate.selectedEmotion(emotion:)))
            .map { result in
                let emotionRawValue = result[0] as? Int ?? 0
                return Emotion.getEmotionFromIndex(emotionRawValue) ?? .pleasant
            }
    }
}

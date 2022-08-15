//
//  RegistEmotionSelectTopView.swift
//  Archive
//
//  Created by hanwe on 2022/08/14.
//

import UIKit
import Then
import SnapKit
import RxCocoa
import RxSwift

@objc protocol RegistEmotionSelectTopViewDelegate: AnyObject {
    @objc optional func clickedSelectEmotion()
}

class RegistEmotionSelectTopView: UIView {
    
    // MARK: private UI property
    
    private let mainContainerView = UIView().then {
        $0.backgroundColor = .clear
        $0.layer.cornerRadius = 8
        $0.layer.borderWidth = 1
        $0.layer.borderColor = Gen.Colors.black.color.cgColor
    }
    
    private let emotionImgView = UIImageView().then {
        $0.image = Emotion.pleasant.miniImage
    }
    
    private let emotionLabel = UILabel().then {
        $0.font = .fonts(.subTitle)
        $0.textColor = Gen.Colors.black.color
        $0.text = "전시가 어땠나요?"
    }
    
    private let moreImgView = UIImageView().then {
        $0.image = Gen.Images.expandMoreBlack24dp.image
    }
    
    private lazy var btn = UIButton().then {
        $0.backgroundColor = .clear
        $0.addTarget(self, action: #selector(clickedSelectEmotion), for: .touchUpInside)
    }
    
    // MARK: internal UI property
    
    // MARK: property
    
    var emotion: Emotion? {
        didSet {
            guard let emotion = emotion else { return }
            DispatchQueue.main.async { [weak self] in
                self?.refresshUI(emotion)
            }
        }
    }
    
    weak var delegate: RegistEmotionSelectTopViewDelegate?
    
    // MARK: private Property
    
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
        self.addSubview(self.mainContainerView)
        self.mainContainerView.snp.makeConstraints {
            $0.edges.equalTo(self)
            $0.height.equalTo(52)
        }
        
        self.mainContainerView.addSubview(self.emotionImgView)
        self.emotionImgView.snp.makeConstraints {
            $0.width.height.equalTo(24)
            $0.leading.equalTo(self.mainContainerView).offset(16)
            $0.centerY.equalTo(self.mainContainerView)
        }
        
        self.mainContainerView.addSubview(self.emotionLabel)
        self.emotionLabel.snp.makeConstraints {
            $0.leading.equalTo(self.emotionImgView.snp.trailing).offset(8)
            $0.centerY.equalTo(self.mainContainerView)
        }
        
        self.mainContainerView.addSubview(self.moreImgView)
        self.moreImgView.snp.makeConstraints {
            $0.leading.equalTo(self.emotionLabel.snp.trailing).offset(8)
            $0.centerY.equalTo(self.mainContainerView)
            $0.trailing.equalTo(self.mainContainerView).offset(-16)
        }
        
        self.mainContainerView.addSubview(self.btn)
        self.btn.snp.makeConstraints {
            $0.edges.equalTo(self.mainContainerView)
        }
        
    }
    
    private func refresshUI(_ emotion: Emotion) {
        self.emotionImgView.image = emotion.miniImage
        self.emotionLabel.text = emotion.localizationTitle
    }
    
    @objc private func clickedSelectEmotion() {
        self.delegate?.clickedSelectEmotion?()
    }
    
    // MARK: func
    
}

class RegistEmotionSelectTopViewDelegateProxy: DelegateProxy<RegistEmotionSelectTopView, RegistEmotionSelectTopViewDelegate>, DelegateProxyType, RegistEmotionSelectTopViewDelegate {
    
    
    static func currentDelegate(for object: RegistEmotionSelectTopView) -> RegistEmotionSelectTopViewDelegate? {
        return object.delegate
    }
    
    static func setCurrentDelegate(_ delegate: RegistEmotionSelectTopViewDelegate?, to object: RegistEmotionSelectTopView) {
        object.delegate = delegate
    }
    
    static func registerKnownImplementations() {
        self.register { (view) -> RegistEmotionSelectTopViewDelegateProxy in
            RegistEmotionSelectTopViewDelegateProxy(parentObject: view, delegateProxy: self)
        }
    }
}

extension Reactive where Base: RegistEmotionSelectTopView {
    var delegate: DelegateProxy<RegistEmotionSelectTopView, RegistEmotionSelectTopViewDelegate> {
        return RegistEmotionSelectTopViewDelegateProxy.proxy(for: self.base)
    }
    
    var clickedSelectEmotion: Observable<Void> {
        return delegate.methodInvoked(#selector(RegistEmotionSelectTopViewDelegate.clickedSelectEmotion))
            .map { result in
                return ()
            }
    }
}

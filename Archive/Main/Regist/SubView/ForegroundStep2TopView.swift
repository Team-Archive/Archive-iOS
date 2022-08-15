//
//  ForegroundStep2TopView.swift
//  Archive
//
//  Created by hanwe on 2022/08/15.
//

import UIKit
import Then
import SnapKit
import RxCocoa
import RxSwift

@objc protocol ForegroundStep2TopViewDelegate: AnyObject {
    @objc optional func selectImage()
}

class ForegroundStep2TopView: UIView {

    // MARK: private UI property
    
    private let mainContentsView = UIView().then {
        $0.backgroundColor = Gen.Colors.gray05.color
    }
    
    private let emotionCoverView = UIImageView().then {
        $0.image = Emotion.pleasant.coverAlphaImage
    }
    
    private let emptyView = UIView().then {
        $0.backgroundColor = Gen.Colors.gray05.color
    }
    
    private let addIconImgView = UIImageView().then {
        $0.image = Gen.Images.addPhoto.image
    }
    
    private lazy var btn = UIButton().then {
        $0.backgroundColor = .clear
        $0.addTarget(self, action: #selector(clickedSelectImage), for: .touchUpInside)
    }
    
    private let upIconImgView = UIImageView().then {
        $0.image = Gen.Images.iconDropUp.image
    }
    
    // MARK: internal UI property
    
    // MARK: property
    
    var emotion: Emotion? {
        didSet {
            guard let emotion = self.emotion else { return }
            DispatchQueue.main.async { [weak self] in
                self?.refreshEmotionUI(emotion: emotion)
            }
        }
    }
    
    // MARK: private Property
    
    weak var delegate: ForegroundStep2TopViewDelegate?
    
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
        self.backgroundColor = .clear
        
        self.addSubview(self.mainContentsView)
        self.mainContentsView.snp.makeConstraints {
            $0.edges.equalTo(self)
        }
        
        self.mainContentsView.addSubview(self.emptyView)
        self.emptyView.snp.makeConstraints {
            $0.leading.equalTo(self.mainContentsView).offset(32)
            $0.trailing.equalTo(self.mainContentsView).offset(-32)
            $0.height.equalTo(UIScreen.main.bounds.width - 64)
            $0.bottom.equalTo(self.mainContentsView).offset(-75)
        }
        
        self.emptyView.addSubview(self.addIconImgView)
        self.addIconImgView.snp.makeConstraints {
            $0.width.height.equalTo(44)
            $0.center.equalTo(self.emptyView)
        }
        
        self.mainContentsView.addSubview(self.emotionCoverView)
        self.emotionCoverView.snp.makeConstraints {
            $0.edges.equalTo(self.emptyView)
        }
        
        self.emptyView.addSubview(self.btn)
        self.btn.snp.makeConstraints {
            $0.edges.equalTo(self.emptyView)
        }
        
        self.mainContentsView.addSubview(self.upIconImgView)
        self.upIconImgView.snp.makeConstraints {
            $0.width.height.equalTo(44)
            $0.bottom.equalTo(self.mainContentsView)
            $0.centerX.equalTo(self.mainContentsView)
        }
    }
    
    private func refreshEmotionUI(emotion: Emotion) {
        self.mainContentsView.backgroundColor = emotion.color
        self.emotionCoverView.image = emotion.coverAlphaImage
    }
    
    @objc private func clickedSelectImage() {
        self.delegate?.selectImage?()
    }
    
    // MARK: func

}

class ForegroundStep2TopViewDelegateProxy: DelegateProxy<ForegroundStep2TopView, ForegroundStep2TopViewDelegate>, DelegateProxyType, ForegroundStep2TopViewDelegate {
    
    
    static func currentDelegate(for object: ForegroundStep2TopView) -> ForegroundStep2TopViewDelegate? {
        return object.delegate
    }
    
    static func setCurrentDelegate(_ delegate: ForegroundStep2TopViewDelegate?, to object: ForegroundStep2TopView) {
        object.delegate = delegate
    }
    
    static func registerKnownImplementations() {
        self.register { (view) -> ForegroundStep2TopViewDelegateProxy in
            ForegroundStep2TopViewDelegateProxy(parentObject: view, delegateProxy: self)
        }
    }
}

extension Reactive where Base: ForegroundStep2TopView {
    var delegate: DelegateProxy<ForegroundStep2TopView, ForegroundStep2TopViewDelegate> {
        return ForegroundStep2TopViewDelegateProxy.proxy(for: self.base)
    }
    
    var selectImage: Observable<Void> {
        return delegate.methodInvoked(#selector(ForegroundStep2TopViewDelegate.selectImage))
            .map { result in
                return ()
            }
    }
}

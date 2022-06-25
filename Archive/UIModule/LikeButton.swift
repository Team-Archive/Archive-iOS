//
//  LikeButton.swift
//  Archive
//
//  Created by hanwe on 2022/06/25.
//

import UIKit
import RxSwift
import RxCocoa

@objc protocol LikeButtonDelegate {
    @objc optional func likeButtonClicked(button: LikeButton, willIsLike: Bool)
}

class LikeButton: UIView {
    
    // MARK: UI property
    
    private let mainContentsView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private let likeImageView = UIImageView().then {
        $0.image = Gen.Images.unlike.image
    }
    
    private lazy var likeRealBtn = UIButton().then {
        $0.backgroundColor = .clear
        $0.addTarget(self, action: #selector(likeClicked), for: .touchUpInside)
    }
    
    // MARK: private property
    
    private var impactFeedbackGenerator: UIImpactFeedbackGenerator?
    
    // MARK: internal property
    
    weak var delegate: LikeButtonDelegate?
    
    var isLike: Bool = false {
        didSet {
            let isLike = self.isLike
            DispatchQueue.main.async { [weak self] in
                if isLike {
                    self?.likeImageView.image = Gen.Images.addArchive.image // 임시
                } else {
                    self?.likeImageView.image = Gen.Images.unlike.image
                }
            }
        }
    }
    
    // MARK: lifeCycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: private function
    
    private func setup() {
        self.addSubview(self.mainContentsView)
        self.mainContentsView.snp.makeConstraints {
            $0.edges.equalTo(self.snp.edges)
        }
        
        self.mainContentsView.addSubview(self.likeImageView)
        self.likeImageView.snp.makeConstraints {
            $0.edges.equalTo(self.mainContentsView)
        }
        
        self.mainContentsView.addSubview(self.likeRealBtn)
        self.likeRealBtn.snp.makeConstraints {
            $0.edges.equalTo(self.mainContentsView)
        }
        
    }
    
    private func likeAnimation(completion: @escaping () -> Void) {
        completion()
    }
    
    private func unlikeAnimation(completion: @escaping () -> Void) {
        completion()
    }
    
    // MARK: function
    
    private func haptic() {
        DispatchQueue.main.async { [weak self] in
            self?.impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
            self?.impactFeedbackGenerator?.impactOccurred()
        }
    }
    
    // MARK: Action
    
    @objc private func likeClicked() {
        haptic()
        if self.isLike {
            self.delegate?.likeButtonClicked?(button: self, willIsLike: false)
            self.unlikeAnimation { [weak self] in
                self?.isLike = false
            }
        } else {
            self.delegate?.likeButtonClicked?(button: self, willIsLike: true)
            self.likeAnimation { [weak self] in
                self?.isLike = true
            }
        }
    }
    

}

class LikeButtonDelegateProxy: DelegateProxy<LikeButton, LikeButtonDelegate>, DelegateProxyType, LikeButtonDelegate {
    
    static func currentDelegate(for object: LikeButton) -> LikeButtonDelegate? {
        return object.delegate
    }
    
    static func setCurrentDelegate(_ delegate: LikeButtonDelegate?, to object: LikeButton) {
        object.delegate = delegate
    }
    
    static func registerKnownImplementations() {
        self.register { (view) -> LikeButtonDelegateProxy in
            LikeButtonDelegateProxy(parentObject: view, delegateProxy: self)
        }
    }
}

extension Reactive where Base: LikeButton {
    var delegate: DelegateProxy<LikeButton, LikeButtonDelegate> {
        return LikeButtonDelegateProxy.proxy(for: self.base)
    }
    
    var likeClicked: Observable<Bool> {
        return delegate.methodInvoked(#selector(LikeButtonDelegate.likeButtonClicked(button:willIsLike:)))
            .map { result in
                return result[1] as? Bool ?? false
            }
    }
}

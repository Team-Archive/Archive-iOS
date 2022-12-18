//
//  FlipView.swift
//  FlipAnimation
//
//  Created by hanwe on 2021/10/02.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift
import Spring // TODO: flip animation을 여기있는 플립으로 바꾸면 더 이쁨, 근데 애니메이션 중간 뷰를 바꿔야해서 중간에 호출되는 핸들러를 만들어야할 듯

@objc public protocol HWFlipViewDelegate: AnyObject {
    @objc optional func flipViewWillFliped(flipView: HWFlipView, foregroundView: UIView, behindeView: UIView, willShow: HWFlipView.FlipType)
    @objc optional func flipViewDidFliped(flipView: HWFlipView, foregroundView: UIView, behindeView: UIView, didShow: HWFlipView.FlipType)
}

public class HWFlipView: UIView {
    
    @objc public enum FlipType: Int {
        case foreground = 0
        case behind
        
        static func getFromRawValue(_ value: Int) -> FlipType {
            var returnValue: FlipType = .foreground
            if value == 1 {
                returnValue = .behind
            }
            return returnValue
        }
    }
    
    // MARK: private property
    private let foregroundView: UIView
    private let behindView: UIView
    private(set) var currentFlipType: FlipType = .foreground
    private let containerView: UIView = UIView()
    private var feedbackGenerator: UIImpactFeedbackGenerator?
    
    // MARK: internal property
    public weak var delegate: HWFlipViewDelegate?
    
    // MARK: lifeCycle
    
    override init(frame: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(foregroundView: UIView, behindView: UIView) {
        self.foregroundView = foregroundView
        self.behindView = behindView
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        setup()
        setGenerator()
    }
    
    deinit {
        print("\(self) deinit")
    }
    
    // MARK: private function
    
    private func setGenerator() {
        self.feedbackGenerator = UIImpactFeedbackGenerator(style: .soft)
        self.feedbackGenerator?.prepare()
    }
    
    private func setup() {
        self.addSubview(self.containerView)
        self.containerView.snp.makeConstraints {
            $0.edges.equalTo(self)
        }
        
        self.containerView.addSubview(foregroundView)
        self.foregroundView.snp.makeConstraints {
            $0.edges.equalTo(self.containerView)
        }
        
        self.containerView.addSubview(behindView)
        behindView.snp.makeConstraints {
            $0.edges.equalTo(self.containerView)
        }
        self.behindView.isHidden = true
        
        self.containerView.backgroundColor = .white
    }
    
    private func flip(type: FlipType, complition: (() -> Void)?) {
        let willtransType: FlipType = type == .behind ? .foreground : .behind
        
        self.delegate?.flipViewWillFliped?(flipView: self, foregroundView: foregroundView, behindeView: behindView, willShow: willtransType)
        
        switch willtransType {
        case .foreground:
            self.foregroundView.isHidden = false
            self.behindView.isHidden = true
        case .behind:
            self.foregroundView.isHidden = true
            self.behindView.isHidden = false
        }
        self.feedbackGenerator?.impactOccurred()
        UIView.transition(with: self.containerView, duration: 0.5, options: .transitionFlipFromTop, animations: nil, completion: { [weak self] isEndAnimation in
            if isEndAnimation {
                guard let self = self else { return }
                self.delegate?.flipViewDidFliped?(flipView: self, foregroundView: self.foregroundView, behindeView: self.behindView, didShow: willtransType)
                self.currentFlipType = willtransType
                complition?()
            }
        })
    }
    
    // MARK: internal function
    
    public func flip(complition: (() -> Void)?) {
        flip(type: self.currentFlipType, complition: complition)
    }
    
}

class HWFlipViewDelegateProxy: DelegateProxy<HWFlipView, HWFlipViewDelegate>, DelegateProxyType, HWFlipViewDelegate {
    
    
    static func currentDelegate(for object: HWFlipView) -> HWFlipViewDelegate? {
        return object.delegate
    }
    
    static func setCurrentDelegate(_ delegate: HWFlipViewDelegate?, to object: HWFlipView) {
        object.delegate = delegate
    }
    
    static func registerKnownImplementations() {
        self.register { (view) -> HWFlipViewDelegateProxy in
            HWFlipViewDelegateProxy(parentObject: view, delegateProxy: self)
        }
    }
}

extension Reactive where Base: HWFlipView {
    var delegate: DelegateProxy<HWFlipView, HWFlipViewDelegate> {
        return HWFlipViewDelegateProxy.proxy(for: self.base)
    }
    
    var didFliped: Observable<HWFlipView.FlipType> {
        return delegate.methodInvoked(#selector(HWFlipViewDelegate.flipViewDidFliped(flipView:foregroundView:behindeView:didShow:)))
            .map { result in
                let rawValue = result[3] as? Int ?? 0
                return HWFlipView.FlipType.getFromRawValue(rawValue)
            }
    }
}

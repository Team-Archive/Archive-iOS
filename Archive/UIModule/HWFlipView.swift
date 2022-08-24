//
//  FlipView.swift
//  FlipAnimation
//
//  Created by hanwe on 2021/10/02.
//

import UIKit
import SnapKit

public protocol HWFlipViewDelegate: AnyObject {
    func flipViewWillFliped(flipView: HWFlipView, foregroundView: UIView, behindeView: UIView, willShow: HWFlipView.FlipType)
    func flipViewDidFliped(flipView: HWFlipView, foregroundView: UIView, behindeView: UIView, didShow: HWFlipView.FlipType)
}

public class HWFlipView: UIView {
    
    public enum FlipType {
        case foreground
        case behind
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
        self.feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
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
        
        self.delegate?.flipViewWillFliped(flipView: self, foregroundView: foregroundView, behindeView: behindView, willShow: willtransType)
        
        switch willtransType {
        case .foreground:
            self.foregroundView.isHidden = false
            self.behindView.isHidden = true
        case .behind:
            self.foregroundView.isHidden = true
            self.behindView.isHidden = false
        }
        UIView.transition(with: self.containerView, duration: 0.5, options: .transitionFlipFromTop, animations: nil, completion: { [weak self] isEndAnimation in
            if isEndAnimation {
                guard let self = self else { return }
                self.delegate?.flipViewDidFliped(flipView: self, foregroundView: self.foregroundView, behindeView: self.behindView, didShow: willtransType)
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

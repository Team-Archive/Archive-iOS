//
//  RegistContentsBottomView.swift
//  Archive
//
//  Created by hanwe on 2022/08/20.
//

import UIKit
import Then
import SnapKit
import RxSwift
import RxCocoa

@objc protocol RegistContentsBottomViewDelegate: AnyObject {
    @objc optional func confrimedRegistContents(text: String, index: Int)
}

class RegistContentsBottomView: UIView {

    // MARK: private UI property
    
    private let mainContentsView = UIView().then {
        $0.backgroundColor = Gen.Colors.white.color
    }
    
    private let textView = PlaceHolderTextView().then {
        $0.placeHolder = "이 작품의 감상은 어땠어요?"
        $0.font = .fonts(.body)
    }
    
    // MARK: internal UI property
    
    // MARK: property
    
    weak var delegate: RegistContentsBottomViewDelegate?
    var index: Int = 1
    
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
        self.backgroundColor = .clear
        
        self.addSubview(self.mainContentsView)
        self.mainContentsView.snp.makeConstraints {
            $0.edges.equalTo(self)
        }
        
        self.mainContentsView.addSubview(textView)
        self.textView.snp.makeConstraints {
            $0.top.equalTo(self.mainContentsView).offset(37)
            $0.leading.equalTo(self.mainContentsView).offset(32)
            $0.trailing.equalTo(self.mainContentsView).offset(-32)
            $0.bottom.equalTo(self.mainContentsView).offset(-20)
        }
        
        let eventNameTextViewDoneButton = UIBarButtonItem.init(title: "완료", style: .done, target: self, action: #selector(self.titleTextViewDone))
        let eventNameTextViewToolBar = UIToolbar.init(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: 44))
        eventNameTextViewToolBar.setItems([UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil), eventNameTextViewDoneButton], animated: true)
        self.textView.customInputAccessoryView = eventNameTextViewToolBar
    }
    
    @objc private func titleTextViewDone() {
        self.delegate?.confrimedRegistContents?(text: self.textView.text, index: self.index)
    }
    
    // MARK: func
    
    func setContents(_ text: String) {
        if text != "" {
            self.textView.text = text
        } else {
            self.textView.clearText()
        }
    }

}

class RegistContentsBottomViewDelegateProxy: DelegateProxy<RegistContentsBottomView, RegistContentsBottomViewDelegate>, DelegateProxyType, RegistContentsBottomViewDelegate {
    
    
    static func currentDelegate(for object: RegistContentsBottomView) -> RegistContentsBottomViewDelegate? {
        return object.delegate
    }
    
    static func setCurrentDelegate(_ delegate: RegistContentsBottomViewDelegate?, to object: RegistContentsBottomView) {
        object.delegate = delegate
    }
    
    static func registerKnownImplementations() {
        self.register { (view) -> RegistContentsBottomViewDelegateProxy in
            RegistContentsBottomViewDelegateProxy(parentObject: view, delegateProxy: self)
        }
    }
}

extension Reactive where Base: RegistContentsBottomView {
    var delegate: DelegateProxy<RegistContentsBottomView, RegistContentsBottomViewDelegate> {
        return RegistContentsBottomViewDelegateProxy.proxy(for: self.base)
    }
    
    var confirmed: Observable<(String, Int)> {
        return delegate.methodInvoked(#selector(RegistContentsBottomViewDelegate.confrimedRegistContents(text:index:)))
            .map { result in
                let contents = result[0] as? String ?? ""
                let index = result[1] as? Int ?? 1
                return (contents, index)
            }
    }
}

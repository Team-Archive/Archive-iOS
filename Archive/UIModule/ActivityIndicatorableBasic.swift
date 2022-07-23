//
//  ActivityIndicatorableBasic.swift
//  Archive
//
//  Created by hanwe on 2022/07/21.
//

import UIKit

protocol ActivityIndicatorableBasic where Self: UIViewController {
    func startBasicIndicatorAnimating()
    func stopBasicIndicatorAnimating()
}

private var ActivityIndicatorableBasicAssociatedObjectKey: Void?

extension ActivityIndicatorableBasic {
    private var indicatorView: UIActivityIndicatorView {
        get {
            var indicator = objc_getAssociatedObject(self, &ActivityIndicatorableBasicAssociatedObjectKey) as? UIActivityIndicatorView
            if indicator == nil {
                indicator = UIActivityIndicatorView()
                if #available(iOS 13.0, *) {
                    indicator?.style = .large
                } else {
                    indicator?.style = .whiteLarge
                }
                objc_setAssociatedObject(self, &ActivityIndicatorableBasicAssociatedObjectKey, indicator, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            return indicator!
        }
        set {
            objc_setAssociatedObject(self, &ActivityIndicatorableBasicAssociatedObjectKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func startBasicIndicatorAnimating() {
        view.addSubview(indicatorView)
        indicatorView.centerInSuperview()
        view.bringSubviewToFront(indicatorView)
        indicatorView.startAnimating()
    }
    
    func stopBasicIndicatorAnimating() {
        indicatorView.removeFromSuperview()
    }
}

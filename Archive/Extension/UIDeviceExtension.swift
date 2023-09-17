//
//  UIDeviceExtension.swift
//  Archive
//
//  Created by hanwe on 2021/10/31.
//

import UIKit

extension UIDevice {
  
  var hasNotch: Bool {
    let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
    let bottom = window?.safeAreaInsets.bottom ?? 0
    return bottom > 0
  }
  
  static var topSafeArea: Double {
    let window = UIApplication.shared.windows.first
    if #available(iOS 13.0, *) {
      return Double(window?.safeAreaInsets.top ?? 0.0)
    }
  }
  
  static var bottomSafeArea: Double {
    let window = UIApplication.shared.windows.first
    if #available(iOS 13.0, *) {
      return Double(window?.safeAreaInsets.bottom ?? 0.0)
    }
  }
  
  static var screenWidth: CGFloat? {
    let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
    return window?.screen.bounds.size.width
  }
  
  static var screenHeight: CGFloat? {
    let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
    return window?.screen.bounds.size.height
  }
  
}

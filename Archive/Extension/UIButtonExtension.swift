//
//  UIButtonExtension.swift
//  Archive
//
//  Created by TTOzzi on 2021/10/16.
//

import UIKit

extension UIButton {
    func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setFillColor(color.cgColor)
        context.fill(CGRect(x: .zero, y: .zero, width: 1, height: 1))
        let backgroundImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        setBackgroundImage(backgroundImage, for: state)
    }
    
    func setImageAllState(_ image: UIImage? = nil) {
        setImage(image, for: .normal)
        setImage(image, for: .highlighted)
        setImage(image, for: .disabled)
        setImage(image, for: .selected)
    }
    
    func setTitleAllState(_ title: String) {
        self.setTitle(title, for: .normal)
        self.setTitle(title, for: .highlighted)
        self.setTitle(title, for: .selected)
        self.setTitle(title, for: .focused)
        self.setTitle(title, for: .disabled)
    }
}

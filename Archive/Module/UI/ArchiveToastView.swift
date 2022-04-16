//
//  ArchiveToastView.swift
//  Archive
//
//  Created by hanwe on 2022/04/16.
//

import UIKit
import SnapKit
import SwiftyTimer

final class ArchiveToastView: UIView {
    
    // MARK: private property
    private let toastView: UIView
    private let messageLabel: UILabel = UILabel()
    
    // MARK: property
    
    // MARK: private function
    
    private static func makeToastView() -> UIView {
        let view: UIView = UIView()
        view.backgroundColor = Gen.Colors.gray03.color
        view.layer.cornerRadius = 8

        return view
    }
    
    private func attatchToastView() {
        messageLabel.font = .fonts(.body)
        messageLabel.textColor = Gen.Colors.white.color
        self.toastView.addSubview(self.messageLabel)
        self.messageLabel.snp.makeConstraints {
            $0.leading.equalTo(self.toastView.snp.leading).offset(20)
            $0.trailing.equalTo(self.toastView.snp.trailing).offset(-20)
            $0.top.equalTo(self.toastView.snp.top).offset(12)
            $0.bottom.equalTo(self.toastView.snp.bottom).offset(-12)
        }
        
        self.addSubview(toastView)
        self.toastView.snp.makeConstraints {
            $0.leading.equalTo(self.snp.leading).offset(32)
            $0.trailing.equalTo(self.snp.trailing).offset(-32)
            $0.top.equalTo(self.snp.top).offset(44)
        }
    }
    
    // MARK: function
    static let shared: ArchiveToastView = {
        let instance = ArchiveToastView()
        instance.frame = UIScreen.main.bounds
        let scene = UIApplication.shared.connectedScenes.first
        if let sd: SceneDelegate = (scene?.delegate as? SceneDelegate) {
            instance.isHidden = true
            instance.alpha = 0
            sd.window?.addSubview(instance)
        }
        return instance
    }()
    
    override init(frame: CGRect) {
        self.toastView = ArchiveToastView.makeToastView()
        super.init(frame: frame)
        self.backgroundColor = .clear
        attatchToastView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private struct ScreenSize {
        static let Width         = UIScreen.main.bounds.size.width
        static let Height        = UIScreen.main.bounds.size.height
        static let Max_Length    = max(ScreenSize.Width, ScreenSize.Height)
        static let Min_Length    = min(ScreenSize.Width, ScreenSize.Height)
    }
    
    func show(message: String, during: TimeInterval = 2, completeHandler: (() -> Void)?) {
        DispatchQueue.main.async {
            self.messageLabel.text = message
            self.layoutIfNeeded()
            self.isHidden = false
            self.fadeIn(completeHandler: completeHandler)
            Timer.after(during.seconds) {
                self.hide()
            }
        }
    }
    
    
    func hide(_ completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            self.fadeOut {
                self.removeAllSubview()
                self.isHidden = true
                completion?()
            }
        }
    }
    
}

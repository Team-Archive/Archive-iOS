//
//  RegistPhotoSelectAlbumButtonView.swift
//  Archive
//
//  Created by hanwe on 2023/09/02.
//

import UIKit
import RxCocoa
import Then
import SnapKit
import RxSwift

@objc protocol RegistPhotoSelectAlbumButtonViewDelegate: AnyObject {
  @objc optional func requestAlbumSelect(_ view: RegistPhotoSelectAlbumButtonView)
}

final class RegistPhotoSelectAlbumButtonView: UIView {
  
  // MARK: UIProperty
  
  private let baseView = UIView().then {
    $0.backgroundColor = .clear
  }
  
  private let contentsLabel = UILabel().then {
    $0.font = .fonts(.subTitle)
    $0.textColor = Gen.Colors.black.color
    $0.text = "최근 항목"
  }
  
  private let iconImageView = UIImageView().then {
    $0.image = Gen.Images.downMiniArrow.image.withRenderingMode(.alwaysTemplate)
    $0.tintColor = Gen.Colors.black.color
  }
  
  private lazy var button = UIButton().then {
    $0.addTarget(self, action: #selector(touchUpInside), for: .touchUpInside)
    $0.addTarget(self, action: #selector(touchUpOutside), for: .touchUpOutside)
    $0.addTarget(self, action: #selector(touchDown), for: .touchDown)
    $0.addTarget(self, action: #selector(touchCancel), for: .touchCancel)
  }
  
  // MARK: private property
  
  // MARK: internal property
  
  weak var delegate: RegistPhotoSelectAlbumButtonViewDelegate?
  
  // MARK: lifeCycle
  
  init() {
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: private function
  
  private func setup() {
    
    self.baseView.setSnpLayout(baseView: self, layoutConstraint: {
      $0.edges.equalToSuperview()
    })
    
    self.contentsLabel.setSnpLayout(baseView: self.baseView, layoutConstraint: {
      $0.leading.centerY.equalToSuperview()
    })
    
    self.iconImageView.setSnpLayout(baseView: self.baseView, layoutConstraint: {
      $0.trailing.centerY.equalToSuperview()
      $0.width.height.equalTo(24)
      $0.leading.equalTo(self.contentsLabel.snp.trailing)
    })
    
    self.button.setSnpLayout(baseView: self.baseView, layoutConstraint: {
      $0.edges.equalToSuperview()
    })
    
  }
  
  @objc private func touchUpInside(_ recognizer: UITapGestureRecognizer) {
    self.contentsLabel.textColor = Gen.Colors.black.color
    self.iconImageView.tintColor = Gen.Colors.black.color
    self.delegate?.requestAlbumSelect?(self)
  }
  
  @objc private func touchUpOutside(_ recognizer: UITapGestureRecognizer) {
    self.contentsLabel.textColor = Gen.Colors.black.color
    self.iconImageView.tintColor = Gen.Colors.black.color
  }
  
  @objc private func touchDown(_ recognizer: UITapGestureRecognizer) {
    self.contentsLabel.textColor = Gen.Colors.gray03.color
    self.iconImageView.tintColor = Gen.Colors.gray03.color
  }
  
  @objc private func touchCancel(_ recognizer: UITapGestureRecognizer) {
    self.contentsLabel.textColor = Gen.Colors.black.color
    self.iconImageView.tintColor = Gen.Colors.black.color
  }
  
  // MARK: internal function
  
  func setTitle(_ title: String) {
    self.contentsLabel.text = title
  }
  
  
}

class RegistPhotoSelectAlbumButtonViewDelegateProxy: DelegateProxy<RegistPhotoSelectAlbumButtonView, RegistPhotoSelectAlbumButtonViewDelegate>, DelegateProxyType, RegistPhotoSelectAlbumButtonViewDelegate {
  
  static func registerKnownImplementations() {
    self.register { (viewController) -> RegistPhotoSelectAlbumButtonViewDelegateProxy in
      RegistPhotoSelectAlbumButtonViewDelegateProxy(parentObject: viewController, delegateProxy: self)
    }
  }
  
  static func currentDelegate(for object: RegistPhotoSelectAlbumButtonView) -> RegistPhotoSelectAlbumButtonViewDelegate? {
    return object.delegate
  }
  
  static func setCurrentDelegate(_ delegate: RegistPhotoSelectAlbumButtonViewDelegate?, to object: RegistPhotoSelectAlbumButtonView) {
    object.delegate = delegate
  }
  
}

extension Reactive where Base == RegistPhotoSelectAlbumButtonView {
  
  var delegate: DelegateProxy<RegistPhotoSelectAlbumButtonView, RegistPhotoSelectAlbumButtonViewDelegate> {
    return RegistPhotoSelectAlbumButtonViewDelegateProxy.proxy(for: self.base)
  }
  
  var requestSelectAlbum: Observable<Void> {
    return delegate.methodInvoked(#selector(RegistPhotoSelectAlbumButtonViewDelegate.requestAlbumSelect(_:)))
      .map { param in
        return ()
      }
  }
  
}

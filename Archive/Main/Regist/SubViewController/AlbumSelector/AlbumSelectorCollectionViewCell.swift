//
//  AlbumSelectorCollectionViewCell.swift
//  Archive
//
//  Created by hanwe on 2023/09/02.
//

import UIKit
import SnapKit
import Then
import Photos

final class AlbumSelectorCollectionViewCell: UICollectionViewCell, ClassIdentifiable {
  
  // MARK: UIProperty
  
  private let baseView = UIView().then {
    $0.backgroundColor = Gen.Colors.white.color
  }
  
  private let thumbnailImageView = UIImageView()
  
  private let contentsContainerView = UIView().then {
    $0.backgroundColor = .clear
  }
  
  private let nameLabel = UILabel().then {
    $0.font = .fonts(.subTitle)
    $0.textColor = Gen.Colors.black.color
  }
  
  private let countLabel = UILabel().then {
    $0.font = .fonts(.body)
    $0.textColor = Gen.Colors.black.color
  }
  
  // MARK: private property
  
  // MARK: internal property
  
  // MARK: lifeCycle
  
  override init(frame: CGRect) {
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    self.thumbnailImageView.image = Gen.Images.userImagePlaceHolder.image
  }
  
  // MARK: private function
  
  private func setup() {
    
    self.baseView.setSnpLayout(baseView: self.contentView, layoutConstraint: {
      $0.edges.equalToSuperview()
    })
    
    self.thumbnailImageView.setSnpLayout(baseView: self.baseView, layoutConstraint: {
      $0.leading.bottom.top.equalToSuperview()
      $0.width.equalTo(80)
    })
    
    self.contentsContainerView.setSnpLayout(baseView: self.baseView, layoutConstraint: {
      $0.leading.equalTo(self.thumbnailImageView.snp.trailing).offset(8)
      $0.trailing.equalToSuperview()
      $0.centerY.equalTo(self.thumbnailImageView)
    })
    
    self.nameLabel.setSnpLayout(baseView: self.contentsContainerView, layoutConstraint: {
      $0.top.leading.equalToSuperview()
    })
    
    self.countLabel.setSnpLayout(baseView: self.contentsContainerView, layoutConstraint: {
      $0.bottom.leading.equalToSuperview()
      $0.top.equalTo(self.nameLabel.snp.bottom).offset(4)
    })
  }
  
  // MARK: internal function
  
  func setConfigure(_ infoData: AlbumModel) {
    let assets = PHAsset.fetchAssets(in: infoData.collection, options: nil)
    let firstAsset = assets.firstObject
    if let firstAsset = firstAsset {
      let requestOptions = PHImageRequestOptions()
      requestOptions.isSynchronous = true
      PHImageManager.default().requestImage(for: firstAsset, targetSize: CGSize(width: 80, height: 80), contentMode: .aspectFill, options: requestOptions) { [weak self] (image, _) in
        if let image = image {
          self?.thumbnailImageView.image = image
        }
      }
    } else {
      self.thumbnailImageView.image = Gen.Images.userImagePlaceHolder.image
    }
    self.nameLabel.text = infoData.name
    self.countLabel.text = "\(infoData.count)"
  }
    
}

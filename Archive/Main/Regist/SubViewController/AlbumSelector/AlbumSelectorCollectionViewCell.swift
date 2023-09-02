//
//  AlbumSelectorCollectionViewCell.swift
//  Archive
//
//  Created by hanwe on 2023/09/02.
//

import UIKit
import SnapKit
import Then

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
    $0.font = .fonts(.header2)
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
  
  // MARK: private function
  
  private func setup() {
    
    self.baseView.setSnpLayout(baseView: self.contentView, layoutConstraint: {
      $0.edges.equalToSuperview()
    })
    
    self.thumbnailImageView.setSnpLayout(baseView: self.baseView, layoutConstraint: {
      $0.leading.bottom.top.equalToSuperview()
      $0.height.equalTo(50)
    })
    
    self.contentsContainerView.setSnpLayout(baseView: self.baseView, layoutConstraint: {
      $0.leading.equalTo(self.thumbnailImageView.snp.trailing).offset(8)
      $0.trailing.equalToSuperview()
      $0.centerY.equalToSuperview()
    })
    
    self.nameLabel.setSnpLayout(baseView: self.contentsContainerView, layoutConstraint: {
      $0.top.leading.equalToSuperview()
    })
    
    self.countLabel.setSnpLayout(baseView: self.contentsContainerView, layoutConstraint: {
      $0.bottom.leading.equalToSuperview()
      $0.top.equalTo(self.nameLabel.snp.bottom).offset(12)
    })
  }
  
  // MARK: internal function
  
  func setConfigure(_ infoData: AlbumModel) {
    // TODO: 사진 넣기
//    thumbnailImageView
    self.nameLabel.text = infoData.name
    self.countLabel.text = "\(infoData.count)"
  }
    
}

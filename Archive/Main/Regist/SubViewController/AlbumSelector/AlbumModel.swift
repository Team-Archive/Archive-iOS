//
//  AlbumModel.swift
//  Archive
//
//  Created by hanwe on 2023/09/02.
//

import Foundation
import Photos
import RxDataSources

struct AlbumModel: IdentifiableType, Equatable {
  
  enum ModelType {
    case all(thumbnail: PHAsset?)
    case album(PHAssetCollection)
  }
  
  typealias Identity = UUID
  
  var identity: UUID
  let name: String
  let count: Int
  let type: ModelType
  
  static func == (lhs: AlbumModel, rhs: AlbumModel) -> Bool {
    return lhs.identity == rhs.identity
  }
}

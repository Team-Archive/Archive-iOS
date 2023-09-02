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
  
  typealias Identity = UUID
  
  var identity: UUID
  let name: String
  let count: Int
  let collection: PHAssetCollection
}

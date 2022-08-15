//
//  PhotoUsecase.swift
//  Archive
//
//  Created by hanwe on 2022/08/15.
//

import UIKit
import Photos
import RxSwift

class PhotoUsecase: NSObject {
//    func selectedAssetToImage(comletion: @escaping ([UIImage]) -> Void) {
//        let selectedItems = self.currentState.imageInfos
//        let allKeys = selectedItems.keys
//        var infos: [PhotoFromAlbumModel] = [PhotoFromAlbumModel]()
//        for key in allKeys {
//            if let item = selectedItems[key] {
//                infos.append(item)
//            }
//        }
//        infos.sort(by: { $0.sequenceNum < $1.sequenceNum })
//        var assets: [PHAsset] = [PHAsset]()
//        for item in infos {
//            guard let asset = item.asset else { continue }
//            assets.append(asset)
//        }
//        phAssetToImages(assets, ImageSize: self.recordImageSize, completion: comletion)
//    }
        
    func phAssetToImages(assets: [PHAsset], imageSize: CGSize) -> Observable<Result<[UIImage], ArchiveError>> {
        return Observable.create { [weak self] emitter in
            let manager = PHImageManager.default()
            let option = PHImageRequestOptions()
            option.isSynchronous = true
            var resultImages: [UIImage] = [UIImage]()
            for item in assets {
                manager.requestImage(for: item, targetSize: imageSize, contentMode: .aspectFit, options: option, resultHandler: {(result, info) -> Void in
                    if result != nil {
                        resultImages.append(result!)
                    }
                })
            }
            emitter.onNext(.success(resultImages))
            emitter.onCompleted()
            return Disposables.create()
        }
    }
}

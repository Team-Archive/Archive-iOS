//
//  ImageThemeColorExtraction.swift
//  Archive
//
//  Created by hanwe on 2022/08/20.
//

import UIKit
import RxSwift

class ImageEdit: NSObject {
    
    // MARK: private property
    
    // MARK: internal property
    
    // MARK: lifeCycle
    
    // MARK: private function
    
    // MARK: internal function
    
    func resize(images: [UIImage], scale: CGFloat, completion: @escaping (([UIImage]) -> Void)) {
        DispatchQueue.global().async { [weak self] in
            var responseImages: [UIImage] = [UIImage]()
            for uiImage in images {
                guard let image: CGImage = uiImage.cgImage else { continue }
                let size = CGSize(width: CGFloat(image.width), height: CGFloat(image.height))
                let context = CGContext(
                    data: nil,
                    width: Int(size.width * scale),
                    height: Int(size.height * scale),
                    bitsPerComponent: 8,
                    bytesPerRow: 0,
                    space: CGColorSpaceCreateDeviceRGB(),
                    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
                context.interpolationQuality = .low
                context.draw(image, in: CGRect(origin: .zero, size: size))
                guard let resultImage = context.makeImage() else { continue }
                let resultUIImage: UIImage = UIImage(cgImage: resultImage)
                responseImages.append(resultUIImage)
            }
            completion(responseImages)
        }
    }
    
    func extractColor(images: [UIImage]) -> Observable<Result<[RegistImageInfo], ArchiveError>> {
        return Observable.create { [weak self] emitter in
            self?.resize(images: images, scale: 0.2, completion: { resizedimages in
                var returnValue: [RegistImageInfo] = []
                for i in 0..<resizedimages.count {
                    let item = resizedimages[i]
                    let color = item.getColors()?.background ?? .clear
                    let newElement = RegistImageInfo(image: images[i], color: color)
                    returnValue.append(newElement)
                }
                emitter.onNext(.success(returnValue))
                emitter.onCompleted()
            })
            return Disposables.create()
        }
    }
    
    
}

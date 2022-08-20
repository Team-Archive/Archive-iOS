//
//  ImageColorUsecase.swift
//  Archive
//
//  Created by hanwe on 2022/08/20.
//

import UIKit
import RxSwift

class ImageColorUsecase: NSObject {
    
    // MARK: private property
    
    private let colorExtraction: ImageThemeColorExtraction = ImageThemeColorExtraction()
    
    // MARK: internal property
    
    // MARK: lifeCycle
    
    // MARK: private function
    
    // MARK: internal function
    
    func extractColor(images: [UIImage]) -> Observable<Result<[RegistImageInfo], ArchiveError>> {
        return self.colorExtraction.extractColor(images: images)
    }
    
}

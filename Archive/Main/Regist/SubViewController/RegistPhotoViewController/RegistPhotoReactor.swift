//
//  RegistPhotoReactor.swift
//  Archive
//
//  Created by hanwe on 2022/08/15.
//

import UIKit
import RxSwift
import ReactorKit
import Photos

class RegistPhotoReactor: Reactor {
    
    // MARK: private property
    
    private let useacase: PhotoUsecase = PhotoUsecase()
    
    // MARK: internal property
    
    let initialState: State = State()
    var err: PublishSubject<ArchiveError> = .init()
    
    enum Action {
        case setThumbnailImage(PHAsset)
        case setImageInfos([PHAsset: PhotoFromAlbumModel])
    }
    
    enum Mutation {
        case empty
        case setThumbnailImage(UIImage)
        case setImageInfos([PHAsset: PhotoFromAlbumModel])
    }
    
    struct State {
        var thumbnailImage: UIImage?
        var imageInfos: [PHAsset: PhotoFromAlbumModel] = [PHAsset: PhotoFromAlbumModel]()
    }
    
    // MARK: life cycle
    
    init() {
        
    }
    
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .setThumbnailImage(let asset):
            return self.useacase.phAssetToImages([asset], ImageSize: CGSize(width: 700, height: 700))
                .map { [weak self] result in
                    switch result {
                    case .success(let images):
                        if images.count == 0 {
                            return .empty
                        } else {
                            return .setThumbnailImage(images[0])
                        }
                    case .failure(let err):
                        self?.err.onNext(err)
                        return .empty
                    }
                }
        case .setImageInfos(let infos):
            return .just(.setImageInfos(infos))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .empty:
            break
        case .setThumbnailImage(let image):
            newState.thumbnailImage = image
        case .setImageInfos(let infos):
            newState.imageInfos = infos
        }
        return newState
    }
    
    // MARK: private func
    
    // MARK: internal func
    
}

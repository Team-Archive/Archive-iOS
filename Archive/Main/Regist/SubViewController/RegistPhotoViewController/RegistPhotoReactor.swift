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
  private let imageColorUsecase = ImageColorUsecase()
  
  // MARK: internal property
  
  let initialState: State
  var err: PublishSubject<ArchiveError> = .init()
  var completedImages: PublishSubject<[RegistImageInfo]> = .init()
  let emotion: Emotion
  
  enum Action {
    case setThumbnailImage(PHAsset)
    case clearSelectedImage
    case setImageInfos([PHAsset: PhotoFromAlbumModel])
    case confirm
    case setCropedImage(UIImage)
    case setOriginPhotoInfo([PHAsset: PhotoFromAlbumModel])
  }
  
  enum Mutation {
    case empty
    case setThumbnailImage(UIImage?)
    case setImageInfos([PHAsset: PhotoFromAlbumModel])
    case setIsLoading(Bool)
    case setSelectedImages([UIImage])
    case setOriginPhotoInfo([PHAsset: PhotoFromAlbumModel])
  }
  
  struct State {
    let isUsingCover: Bool
    var thumbnailImage: UIImage?
    var imageInfos: [PHAsset: PhotoFromAlbumModel] = [PHAsset: PhotoFromAlbumModel]()
    var isLoading: Bool = false
    var selectedImageArr: [UIImage] = []
    var originPhotoInfo: [PHAsset: PhotoFromAlbumModel]
  }
  
  // MARK: life cycle
  
  init(emotion: Emotion, originPhotoInfo: [PHAsset: PhotoFromAlbumModel], isUsingCover: Bool) {
    self.emotion = emotion
    self.initialState = .init(isUsingCover: isUsingCover, originPhotoInfo: originPhotoInfo)
  }
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .setThumbnailImage(let asset):
      return self.phAssetToImage(assets: [asset], imageSize: CGSize(width: 700, height: 700))
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
    case .confirm:
      return Observable.concat([
        Observable.just(Mutation.setIsLoading(true)),
        self.phAssetToImage(assets: self.convertPhotoInfo(info: self.currentState.imageInfos),
                            imageSize: CGSize(width: 700, height: 700))
        .map { [weak self] result in
          switch result {
          case .success(let imageArr):
            return .setSelectedImages(imageArr)
          case .failure(let err):
            self?.err.onNext(err)
            return .empty
          }
        },
        Observable.just(Mutation.setIsLoading(false))
      ])
    case .setCropedImage(let image):
      let completedImages = makeCompletedImages(image)
      return Observable.concat([
        Observable.just(Mutation.setIsLoading(true)),
        self.imageColorUsecase.extractColor(images: completedImages)
          .map { [weak self] result in
            switch result {
            case .success(let infos):
              self?.completedImages.onNext(infos)
            case .failure(let err):
              self?.err.onNext(err)
            }
            return .empty
          },
        Observable.just(Mutation.setIsLoading(false))
      ])
    case .setOriginPhotoInfo(let info):
      return .just(.setOriginPhotoInfo(info))
    case .clearSelectedImage:
      return .from([
        .setSelectedImages([]),
        .setThumbnailImage(nil),
        .setImageInfos([:])
      ])
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
    case .setIsLoading(let isLoading):
      newState.isLoading = isLoading
    case .setSelectedImages(let images):
      newState.selectedImageArr = images
    case .setOriginPhotoInfo(let info):
      newState.originPhotoInfo = info
    }
    return newState
  }
  
  // MARK: private func
  
  private func convertPhotoInfo(info: [PHAsset: PhotoFromAlbumModel]) -> [PHAsset] {
    let allKeys = Array(info.keys)
    let returnValue: [PHAsset] = {
      var returnValue = [PHAsset]()
      var modelArr = [PhotoFromAlbumModel]()
      for key in allKeys {
        guard let item = info[key] else { continue }
        modelArr.append(item)
      }
      let sortedModelArr = modelArr.sorted { $0.sequenceNum > $1.sequenceNum }
      for item in sortedModelArr {
        guard let asset = item.asset else { continue }
        returnValue.append(asset)
      }
      return returnValue
    }()
    return returnValue
  }
  
  private func phAssetToImage(assets: [PHAsset], imageSize: CGSize) -> Observable<Result<[UIImage], ArchiveError>> {
    return self.useacase.phAssetToImages(assets: assets, imageSize: imageSize)
  }
  
  private func makeCompletedImages(_ image: UIImage) -> [UIImage] {
    let returnValue: [UIImage] = {
      var returnValue: [UIImage] = []
      returnValue.append(image)
      for i in 0..<self.currentState.selectedImageArr.count {
        if i == 0 { continue }
        returnValue.append(self.currentState.selectedImageArr[i])
      }
      return returnValue
    }()
    return returnValue
  }
  
  // MARK: internal func
  
}

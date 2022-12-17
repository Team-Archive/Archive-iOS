//
//  DetailReactor.swift
//  Archive
//
//  Created by hanwe on 2021/12/04.
//

import UIKit
import ReactorKit
import RxRelay
import RxFlow

class DetailReactor: Reactor, Stepper {
    
    // MARK: private property
    
    private let recordData: ArchiveDetailInfo
    private let index: Int
    private let archiveEditUsecase: ArchiveEditUsecase
    
    // MARK: internal property
    
    let initialState: State
    let steps = PublishRelay<Step>()
    
    // MARK: lifeCycle
    
    init(recordData: ArchiveDetailInfo, index: Int, isPublic: Bool, archiveEditRepository: ArchiveEditRepository) {
        self.initialState = .init(detailData: recordData, isPublic: isPublic)
        self.recordData = recordData
        self.index = index
        self.archiveEditUsecase = .init(repository: archiveEditRepository)
    }
    
    enum Action {
        case shareToInstagram
        case saveToAlbum
        case openShare(UIActivityViewController)
        case deleteArchive
        case toggleArchiveIsPublic
    }
    
    enum Mutation {
        case setShareActivityController(UIActivityViewController)
        case setIsDeletedArchive(Bool)
        case setLoading(Bool)
        case setIsPublic(Bool)
        case setError(ArchiveError)
        case setIsToggledIsPublicArchive(Void)
    }
    
    struct State {
        var detailData: ArchiveDetailInfo
        var willSharedCarView: UIView?
        var shareActivityController: UIActivityViewController?
        var isDeletedArchive: Bool = false
        var isLoading: Bool = false
        var isPublic: Bool
        var err: Pulse<ArchiveError?> = .init(wrappedValue: nil)
        var isToggledIsPublicArchive: Pulse<Void?> = .init(wrappedValue: nil)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .shareToInstagram:
            GAModule.sendEventLogToGA(.shareInstagramFromDetail)
            DispatchQueue.main.async { [weak self] in
                self?.makeCardView(completion: { cardView in
                    InstagramStoryShareManager.shared.share(view: cardView, backgroundTopColor: cardView.topBackgroundColor, backgroundBottomColor: cardView.bottomBackgroundColor, completion: { _ in
                        
                    }, failure: { _ in
                        
                    })
                })
            }
            return .empty()
        case .saveToAlbum:
            DispatchQueue.main.async { [weak self] in
                self?.makeCardView(completion: { [weak self] cardView in
                    guard let activityViewController = CardShareManager.shared.share(view: cardView) else { return }
                    self?.action.onNext(.openShare(activityViewController))
                })
            }
            return .empty()
        case .openShare(let controller):
            return .just(.setShareActivityController(controller))
        case .deleteArchive:
            return Observable.concat([
                Observable.just(Mutation.setLoading(true)),
                self.deleteArchive(archiveId: "\(self.currentState.detailData.archiveId)").map { result in
                    switch result {
                    case .success(_):
                        return .setIsDeletedArchive(true)
                    case .failure(_):
                        return .setIsDeletedArchive(false)
                    }
                },
                Observable.just(.setIsDeletedArchive(true)),
                Observable.just(Mutation.setLoading(false))
            ])
        case .toggleArchiveIsPublic:
            return Observable.concat([
                Observable.just(Mutation.setLoading(true)),
                self.toggleArchiveIsPublic(
                    archiveId: self.currentState.detailData.archiveId,
                    currentIsPublicState: self.currentState.isPublic
                ).flatMap { [weak self] result -> Observable<Mutation> in
                    switch result {
                    case .success(_):
                        return .from([
                            .setIsToggledIsPublicArchive(()),
                            .setIsPublic(!(self?.currentState.isPublic ?? true))
                        ])
                    case .failure(let err):
                        return .just(.setError(err))
                    }
                },
                Observable.just(Mutation.setLoading(false))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setShareActivityController(let controller):
            newState.shareActivityController = controller
        case .setIsDeletedArchive(let isDeleted):
            newState.isDeletedArchive = isDeleted
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
        case .setIsToggledIsPublicArchive(_):
            newState.isToggledIsPublicArchive = .init(wrappedValue: ())
        case .setError(let err):
            newState.err = .init(wrappedValue: err)
        case .setIsPublic(let isPublic):
            newState.isPublic = isPublic
        }
        return newState
    }
    
    func getIndex() -> Int {
        return self.index
    }
    
    // MARK: private function
    
    private func makeCardView(completion: @escaping (ShareCardView) -> Void) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: URL(string: (self?.recordData.mainImage)!)!) {
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    guard let cardView: ShareCardView = ShareCardView.instance() else { return }
                    cardView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 1.73)
                    cardView.setInfoData(emotion: self.recordData.emotion, thumbnailImage: UIImage(data: data) ?? UIImage(), eventName: self.recordData.name, date: self.recordData.watchedOn)
                    completion(cardView)
                }
            } else {
                completion(ShareCardView())
            }
        }
    }
    
    private func deleteArchive(archiveId: String) -> Observable<Result<Data, Error>> {
        let archiveId: String = archiveId
        let provider = ArchiveProvider.shared.provider
        
        return provider.rx.request(.deleteArchive(archiveId: archiveId), callbackQueue: DispatchQueue.global())
            .asObservable()
            .map { result in
                return .success(result.data)
            }
            .catch { err in
                .just(.failure(err))
            }
    }
    
    private func toggleArchiveIsPublic(archiveId: Int, currentIsPublicState: Bool) -> Observable<Result<Void, ArchiveError>> {
        return self.archiveEditUsecase.switchIsPublicArchive(id: archiveId,
                                                             isPublic: !currentIsPublicState)
    }
    
    // MARK: internal function
}

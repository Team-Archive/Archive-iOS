//
//  RecordFlow.swift
//  Archive
//
//  Created by hanwe on 2022/05/14.
//

import RxFlow

class RecordFlow: Flow {
    
    private enum Constants {
    }
    
    // MARK: private property
    
    private let recordStoryBoard = UIStoryboard(name: "Record", bundle: nil)
    
    private weak var recordViewController: RecordViewController?
    private weak var editEmotionViewController: EmotionSelectViewController?
    private weak var imageSelectViewControllerNavi: UINavigationController?
    
    // MARK: internal property
    
    var root: Presentable {
        return rootViewController
    }
    
    var rootViewController: UINavigationController
    
    // MARK: lifeCycle
    
    init(rootViewController: UINavigationController, recordViewController: RecordViewController) {
        self.rootViewController = rootViewController
        self.recordViewController = recordViewController
    }
    
    // MARK: private function
    
    private func navigationToEditEmotion(currentEmotion: Emotion?) -> FlowContributors {
        let reactor = EmotionSelectReactor(currentEmotion: currentEmotion)
        let emotionSelectViewController: EmotionSelectViewController = EmotionSelectViewController(reactor: reactor)
        emotionSelectViewController.title = ""
        emotionSelectViewController.modalPresentationStyle = .overFullScreen
        self.editEmotionViewController = emotionSelectViewController
        rootViewController.present(emotionSelectViewController, animated: false, completion: {
            emotionSelectViewController.fadeInAnimation()
        })
        return .one(flowContributor: .contribute(withNextPresentable: emotionSelectViewController,
                                                 withNextStepper: reactor))
    }
    
    private func dismissEditEmotion(emotion: Emotion) {
        self.editEmotionViewController?.dismiss(animated: false, completion: nil)
        self.recordViewController?.reactor?.action.onNext(.setEmotion(emotion))
    }
    
    private func navigationToImageSelect(emotion: Emotion) -> FlowContributors {
        let model: ImageSelectModel = ImageSelectModel()
        let reactor = ImageSelectReactor(model: model, emotion: emotion)
        let imageSelectViewController: ImageSelectViewController = recordStoryBoard.instantiateViewController(identifier: ImageSelectViewController.identifier) { corder in
            return ImageSelectViewController(coder: corder, reactor: reactor)
        }
        imageSelectViewController.title = ""
        let navi: UINavigationController = UINavigationController(rootViewController: imageSelectViewController)
        navi.modalPresentationStyle = .fullScreen
        self.imageSelectViewControllerNavi = navi
        rootViewController.present(navi, animated: true, completion: nil)
        return .one(flowContributor: .contribute(withNextPresentable: imageSelectViewController,
                                                 withNextStepper: reactor))
    }
    
    private func dismissImageSelect() {
        self.imageSelectViewControllerNavi?.dismiss(animated: true, completion: {
            self.imageSelectViewControllerNavi?.viewControllers = []
        })
    }
    
    private func navigationToRecordUpload(contents: ContentsRecordModelData, thumbnail: UIImage, emotion: Emotion, imageInfos: [ImageInfo]?) -> FlowContributors {
        let model: RecordUploadModel = RecordUploadModel(contents: contents, thumbnailImage: thumbnail, emotion: emotion, imageInfos: imageInfos)
        let reactor = RecordUploadReactor(model: model)
        let recordUploadViewController: RecordUploadViewController = recordStoryBoard.instantiateViewController(identifier: RecordUploadViewController.identifier) { corder in
            return RecordUploadViewController(coder: corder, reactor: reactor)
        }
        recordUploadViewController.modalPresentationStyle = .fullScreen
        rootViewController.present(recordUploadViewController, animated: true, completion: nil)
        return .one(flowContributor: .contribute(withNextPresentable: recordUploadViewController,
                                                 withNextStepper: reactor))
    }
    
    private func navigationToRecordUploadComplete(thumbnail: UIImage, emotion: Emotion, conetentsInfo: ContentsRecordModelData) -> FlowContributors {
        let model: RecordUploadCompleteModel = RecordUploadCompleteModel(thumbnail: thumbnail, emotion: emotion, contentsInfo: conetentsInfo)
        let reactor = RecordUploadCompleteReactor(model: model)
        let recordUploadCompleteViewController: RecordUploadCompleteViewController = recordStoryBoard.instantiateViewController(identifier: RecordUploadCompleteViewController.identifier) { corder in
            return RecordUploadCompleteViewController(coder: corder, reactor: reactor)
        }
        recordUploadCompleteViewController.modalPresentationStyle = .fullScreen
        rootViewController.present(recordUploadCompleteViewController, animated: false, completion: nil)
        return .one(flowContributor: .contribute(withNextPresentable: recordUploadCompleteViewController,
                                                 withNextStepper: reactor))
    }
    
    // MARK: internal function
    
    func makeNavigationItems() {
        
    }
    
    func navigate(to step: Step) -> FlowContributors {
        
        guard let step = step as? ArchiveStep else { return .none }
        switch step {
        case .recordClose:
            self.rootViewController.dismiss(animated: true)
            return .end(forwardToParentFlowWithStep: ArchiveStep.recordClose)
        case .recordEmotionEditIsRequired(let emotion):
            GAModule.sendEventLogToGA(.startEmotionSelect)
            return navigationToEditEmotion(currentEmotion: emotion)
        case .recordEmotionEditIsComplete(let emotion):
            GAModule.sendEventLogToGA(.completeEmotionSelect(selected: emotion.rawValue))
            dismissEditEmotion(emotion: emotion)
            return .none
        case .recordImageSelectIsRequired(let emotion):
            GAModule.sendEventLogToGA(.startPhotoSelect)
            return navigationToImageSelect(emotion: emotion)
        case .recordImageSelectIsComplete(let thumbnailImage, let images):
            GAModule.sendEventLogToGA(.completePhotoSelect)
            self.recordViewController?.reactor?.action.onNext(.setImages(images))
            self.recordViewController?.reactor?.action.onNext(.setThumbnailImage(thumbnailImage))
            dismissImageSelect()
            return .none
        case .recordUploadIsRequired(let contents, let thumbnail, let emotion, let imageInfos):
            return navigationToRecordUpload(contents: contents, thumbnail: thumbnail, emotion: emotion, imageInfos: imageInfos)
        case .recordUploadIsComplete(let thumbnail, let emotion, let contentsInfo):
            GAModule.sendEventLogToGA(.completeRegistArchive)
            rootViewController.dismiss(animated: false, completion: nil)
            return navigationToRecordUploadComplete(thumbnail: thumbnail, emotion: emotion, conetentsInfo: contentsInfo)
        case .recordComplete:
            rootViewController.dismiss(animated: true, completion: { [weak self] in
//                self?.rootViewController?.popToRootViewController(animated: false)
//                self?.homeViewControllerPtr?.reactor?.action.onNext(.getMyArchives)
//                self?.homeViewControllerPtr?.moveCollectionViewFirstIndex()
                self?.rootViewController.dismiss(animated: false)
            })
            return .end(forwardToParentFlowWithStep: ArchiveStep.recordComplete)
        default:
            return .none
        }
    }
    
}

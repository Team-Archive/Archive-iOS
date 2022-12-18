//
//  CommunityDetailViewController.swift
//  Archive
//
//  Created by hanwe on 2022/06/25.
//

import UIKit
import SnapKit
import ReactorKit
import RxCocoa
import RxSwift
import Then
import Kingfisher
import Spring

class CommunityDetailViewController: UIViewController, View, ActivityIndicatorable {
    
    // MARK: UI property
    
    // navigation
    
    private let userImageView = UIImageView().then {
        $0.backgroundColor = .clear
        $0.image = Gen.Images.userImagePlaceHolder.image
        $0.layer.cornerRadius = 15
        $0.layer.masksToBounds = true
    }
    
    private let userNameLabel = UILabel().then {
        $0.font = .fonts(.button2)
        $0.textColor = Gen.Colors.white.color
    }
    
    private lazy var moreBtn = UIButton().then {
        $0.setImageAllState(Gen.Images.more.image)
        $0.addTarget(self, action: #selector(moreClicked), for: .touchUpInside)
    }
    
    private lazy var closeBtn = UIButton().then {
        $0.setImageAllState(Gen.Images.closeWhite.image)
        $0.addTarget(self, action: #selector(closeClicked), for: .touchUpInside)
    }
    
    // navigation end
    
    private let mainBackgroundView = UIView().then {
        $0.backgroundColor = Gen.Colors.white.color
    }
    
    private lazy var mainContentsView = UIView().then {
        $0.backgroundColor = .clear
        let leftSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        let rightSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        leftSwipeGestureRecognizer.direction = .left
        rightSwipeGestureRecognizer.direction = .right
        $0.addGestureRecognizer(leftSwipeGestureRecognizer)
        $0.addGestureRecognizer(rightSwipeGestureRecognizer)
    }
    
    private lazy var topGradationView = UIImageView().then {
        $0.backgroundColor = .clear
        $0.image = Gen.Images.navigationGradation.image
    }
    
    private let topContentsView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private let bottomContentsView = BottomPaddingCoverView().then {
        $0.backgroundColor = Gen.Colors.white.color
    }
    
    private let likeBtn = LikeButton().then {
        $0.backgroundColor = .clear
    }
    
    private let likeCntLabel = UILabel().then {
        $0.font = .fonts(.body)
        $0.textColor = Gen.Colors.gray03.color
    }
    
    private let leftTriangleView = UIImageView().then {
        $0.image = Gen.Images.triLeft.image
    }
    
    private let rightTriangleView = UIImageView().then {
        $0.image = Gen.Images.triRight.image
    }
    
    private lazy var leftButton = UIButton().then {
        $0.backgroundColor = .clear
        $0.addTarget(self, action: #selector(leftClicked), for: .touchUpInside)
    }
    
    private lazy var rightButton = UIButton().then {
        $0.backgroundColor = .clear
        $0.addTarget(self, action: #selector(rightClicked), for: .touchUpInside)
    }
    
    private lazy var progressBar = ArchiveProgressBar().then {
        $0.backgroundColor = .clear
    }
    
    // type Cover
    
    private let topCoverContentsView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private let topCoverImageView = UIImageView().then {
        $0.backgroundColor = .clear
    }
    
    private let topCoverEmotionCoverView = UIImageView().then {
        $0.backgroundColor = .clear
    }
    
    
    private let bottomCoverContentsView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private let bottomCoverTitleLabel = UILabel().then {
        $0.font = .fonts(.header2)
        $0.textColor = Gen.Colors.black.color
        $0.numberOfLines = 2
    }
    
    private let bottomCoverDateLabel = UILabel().then {
        $0.font = .fonts(.subTitle)
        $0.textColor = Gen.Colors.gray03.color
        $0.numberOfLines = 1
    }
    
//    private let // 친구들 보여줘야할까?
    
    // type Photo
    
    private let topPhotoContentsView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private let bottomPhotoContentsView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private let photoImageView = UIImageView().then {
        $0.backgroundColor = .clear
        $0.contentMode = .scaleAspectFit
    }
    
    private let photoContentsLabel = UILabel().then {
        $0.font = .fonts(.body)
        $0.textColor = Gen.Colors.black.color
        $0.numberOfLines = 5
    }
    
    private let rotatedTitleView = RotatedTitleView().then {
        $0.backgroundColor = .clear
    }
    
    // MARK: private property
    
    private var currentIndex: Int = -1
    private var feedbackGenerator: UIImpactFeedbackGenerator?
    
    // MARK: property
    var disposeBag: DisposeBag = DisposeBag()
    
    // MARK: lifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        makeNavigationItems()
        setGenerator()
    }
    
    init(reactor: CommunityReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    override func loadView() {
        super.loadView()
        
        self.view.addSubview(self.mainBackgroundView)
        self.mainBackgroundView.snp.makeConstraints {
            $0.edges.equalTo(self.view)
        }
        
        self.view.addSubview(self.mainContentsView)
        let safeGuide = self.view.safeAreaLayoutGuide
        self.mainContentsView.snp.makeConstraints {
            $0.top.equalTo(self.view.snp.top)
            $0.bottom.equalTo(safeGuide.snp.bottom)
            $0.leading.equalTo(safeGuide.snp.leading)
            $0.trailing.equalTo(safeGuide.snp.trailing)
        }
        
        self.mainContentsView.addSubview(self.bottomContentsView)
        self.bottomContentsView.snp.makeConstraints {
            $0.bottom.equalTo(self.mainContentsView.snp.bottom)
            $0.leading.equalTo(self.mainContentsView.snp.leading)
            $0.trailing.equalTo(self.mainContentsView.snp.trailing)
            $0.height.equalTo(170)
        }
        
        self.mainContentsView.addSubview(self.topContentsView)
        self.topContentsView.snp.makeConstraints {
            $0.bottom.equalTo(self.bottomContentsView.snp.top)
            $0.top.equalTo(self.mainContentsView.snp.top)
            $0.leading.equalTo(self.mainContentsView.snp.leading)
            $0.trailing.equalTo(self.mainContentsView.snp.trailing)
        }
        
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        let statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        self.view.addSubview(self.topGradationView)
        self.topGradationView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(self.view)
            $0.height.equalTo(statusBarHeight + (self.navigationController?.navigationBar.bounds.height ?? 0))
        }
        self.view.bringSubviewToFront(self.topGradationView)
        
        self.topContentsView.addSubview(self.topCoverContentsView)
        self.topCoverContentsView.snp.makeConstraints {
            $0.edges.equalTo(self.topContentsView)
        }
        
        self.topCoverContentsView.addSubview(self.topCoverImageView)
        self.topCoverImageView.snp.makeConstraints {
            $0.leading.equalTo(self.topCoverContentsView.snp.leading)
            $0.trailing.equalTo(self.topCoverContentsView.snp.trailing)
            $0.height.equalTo(UIScreen.main.bounds.width)
            $0.centerY.equalTo(self.topCoverContentsView.snp.centerY)
        }
        
        self.topCoverContentsView.addSubview(self.topCoverEmotionCoverView)
        self.topCoverEmotionCoverView.snp.makeConstraints {
            $0.leading.equalTo(self.topCoverContentsView.snp.leading)
            $0.trailing.equalTo(self.topCoverContentsView.snp.trailing)
            $0.height.equalTo(UIScreen.main.bounds.width)
            $0.centerY.equalTo(self.topCoverContentsView.snp.centerY)
        }
        
        self.bottomContentsView.addSubview(self.bottomCoverContentsView)
        self.bottomCoverContentsView.snp.makeConstraints {
            $0.edges.equalTo(self.bottomContentsView)
        }
        self.bottomContentsView.makeBottomCoverView()
        
        self.bottomCoverContentsView.addSubview(self.bottomCoverTitleLabel)
        self.bottomCoverTitleLabel.snp.makeConstraints {
            $0.leading.equalTo(self.bottomCoverContentsView.snp.leading).offset(32)
            $0.trailing.equalTo(self.bottomCoverContentsView.snp.trailing).offset(-32)
            $0.top.equalTo(self.bottomCoverContentsView.snp.top).offset(25)
        }
        
        self.bottomCoverContentsView.addSubview(self.bottomCoverDateLabel)
        self.bottomCoverDateLabel.snp.makeConstraints {
            $0.leading.equalTo(self.bottomCoverContentsView.snp.leading).offset(32)
            $0.top.equalTo(self.bottomCoverContentsView.snp.top).offset(106)
        }
        
        self.topContentsView.addSubview(self.topPhotoContentsView)
        self.topPhotoContentsView.snp.makeConstraints {
            $0.edges.equalTo(self.topContentsView)
        }
        
        self.topPhotoContentsView.addSubview(self.photoImageView)
        self.photoImageView.snp.makeConstraints {
            $0.edges.equalTo(self.topPhotoContentsView)
        }
        
        self.topPhotoContentsView.addSubview(self.rotatedTitleView)
        self.rotatedTitleView.snp.makeConstraints {
            $0.leading.equalTo(self.topPhotoContentsView.snp.leading)
            $0.height.equalTo(56)
            $0.centerY.equalTo(self.topPhotoContentsView.snp.centerY).offset(0)
        }
        
        self.bottomContentsView.addSubview(self.bottomPhotoContentsView)
        self.bottomPhotoContentsView.snp.makeConstraints {
            $0.edges.equalTo(self.bottomContentsView)
        }
        
        self.bottomPhotoContentsView.addSubview(self.photoContentsLabel)
        self.photoContentsLabel.snp.makeConstraints {
            $0.top.equalTo(self.bottomPhotoContentsView.snp.top).offset(37)
            $0.leading.equalTo(self.bottomPhotoContentsView.snp.leading).offset(32)
            $0.trailing.equalTo(self.bottomPhotoContentsView.snp.trailing).offset(-32)
        }
        
        
        
        
        
        self.topContentsView.addSubview(self.leftTriangleView)
        self.leftTriangleView.snp.makeConstraints {
            $0.leading.equalTo(self.topCoverContentsView.snp.leading)
            $0.bottom.equalTo(self.topCoverContentsView.snp.bottom).offset(24)
            $0.width.equalTo(48)
            $0.height.equalTo(48)
        }
        
        self.topContentsView.addSubview(self.rightTriangleView)
        self.rightTriangleView.snp.makeConstraints {
            $0.trailing.equalTo(self.topCoverContentsView.snp.trailing)
            $0.bottom.equalTo(self.topCoverContentsView.snp.bottom).offset(24)
            $0.width.equalTo(48)
            $0.height.equalTo(48)
        }
        
        self.topContentsView.addSubview(self.leftButton)
        self.leftButton.snp.makeConstraints {
            $0.leading.equalTo(self.topContentsView.snp.leading)
            $0.top.equalTo(self.topContentsView.snp.top)
            $0.bottom.equalTo(self.topContentsView.snp.bottom)
            $0.width.equalTo(50)
        }
        
        self.topContentsView.addSubview(self.rightButton)
        self.rightButton.snp.makeConstraints {
            $0.trailing.equalTo(self.topContentsView.snp.trailing)
            $0.top.equalTo(self.topContentsView.snp.top)
            $0.bottom.equalTo(self.topContentsView.snp.bottom)
            $0.width.equalTo(50)
        }
        
        self.view.addSubview(self.progressBar)
        self.progressBar.snp.makeConstraints {
            $0.top.equalTo(safeGuide)
            $0.leading.trailing.equalTo(self.mainContentsView)
            $0.height.equalTo(2)
        }
        
        self.bottomContentsView.addSubview(self.likeBtn)
        self.likeBtn.snp.makeConstraints {
            $0.trailing.equalTo(self.bottomContentsView.snp.trailing).offset(-32)
            $0.width.equalTo(40)
            $0.height.equalTo(40)
            $0.bottom.equalTo(self.bottomContentsView.snp.bottom).offset(-32)
        }
        
        self.bottomContentsView.addSubview(self.likeCntLabel)
        self.likeCntLabel.snp.makeConstraints {
            $0.centerX.equalTo(likeBtn.snp.centerX)
            $0.top.equalTo(self.likeBtn.snp.bottom).offset(5)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(reactor: CommunityReactor) {
        
        reactor.err
            .asDriver(onErrorJustReturn: .init(.commonError))
            .drive(onNext: { err in
                CommonAlertView.shared.show(message: err.getMessage(), btnText: "확인", hapticType: .error, confirmHandler: {
                    CommonAlertView.shared.hide(nil)
                })
            })
            .disposed(by: self.disposeBag)
        
        reactor.state
            .map { $0.isLoading }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] in
                if $0 {
                    self?.startIndicatorAnimating()
                } else {
                    self?.stopIndicatorAnimating()
                }
            })
            .disposed(by: self.disposeBag)
        
        reactor.state
            .map { $0.detailArchive }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: .init(archiveInfo: .init(archiveId: 0, authorId: 0, name: "", watchedOn: "", emotion: .fun, companions: nil, mainImage: "", images: nil, nickname: "", profileImage: ""), innerIndex: 0, index: 0))
            .drive(onNext: { [weak self] data in
                if data.innerIndex == 0 {
                    self?.showCover(infoData: data)
                    self?.userNameLabel.text = data.archiveInfo.nickname + "                           "
                    self?.userImageView.kf.setImage(with: URL(string: data.archiveInfo.profileImage),
                                                    placeholder: Gen.Images.userImagePlaceHolder.image,
                                                    options: [.cacheMemoryOnly],
                                                    completionHandler: nil)
                } else {
                    self?.showPhoto(infoData: data)
                    self?.rotatedTitleView.name = data.archiveInfo.name
                    self?.rotatedTitleView.emotion = data.archiveInfo.emotion
                    let rotatedOffset = self?.rotatedTitleView.getRotatedViewOffset() ?? 0
                    self?.rotatedTitleView.snp.updateConstraints {
                        $0.leading.equalTo(self?.topPhotoContentsView.snp.leading ?? 0).offset(rotatedOffset + 28)
                    }
                }
                self?.progressBar.setPercent(
                    self?.getProgressPercent(totalPageCnt: (data.archiveInfo.images?.count ?? 0) + 1,
                                             currentIndex: data.innerIndex) ?? 0
                )
            
            })
            .disposed(by: self.disposeBag)
        
        reactor.state
            .map { $0.detailArchive }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: .init(archiveInfo: .init(archiveId: 0, authorId: 0, name: "", watchedOn: "", emotion: .fun, companions: nil, mainImage: "", images: nil, nickname: "", profileImage: ""), innerIndex: 0, index: 0))
            .drive(onNext: { [weak self] data in
                self?.likeBtn.isLike = LikeManager.shared.likeList.contains("\(data.archiveInfo.archiveId)")
            })
            .disposed(by: self.disposeBag)
        
        self.likeBtn.rx.likeClicked
            .subscribe(onNext: { [weak self] isLike in
                if isLike {
                    guard let archiveId = self?.reactor?.currentState.detailArchive.archiveInfo.archiveId else { return }
                    LikeManager.shared.like(id: "\(archiveId)")
                } else {
                    guard let archiveId = self?.reactor?.currentState.detailArchive.archiveInfo.archiveId else { return }
                    LikeManager.shared.likeCancel(id: "\(archiveId)")
                }
            })
            .disposed(by: self.disposeBag)
        
    }
    
    deinit {
        print("\(self) deinit")
    }
    
    // MARK: private func
    
    private func showCover(infoData: CommunityReactor.DetailInfo) {
        let item = infoData.archiveInfo
        self.topCoverContentsView.isHidden = false
        self.bottomCoverContentsView.isHidden = false
        self.topPhotoContentsView.isHidden = true
        self.bottomPhotoContentsView.isHidden = true
        
        self.mainBackgroundView.backgroundColor = item.emotion.color
        self.topCoverImageView.kf.setImage(with: URL(string: item.mainImage),
                                           placeholder: nil,
                                           options: [.cacheMemoryOnly],
                                           completionHandler: nil)
        self.topCoverEmotionCoverView.image = item.emotion.coverAlphaImage
        self.bottomCoverTitleLabel.text = item.name
        self.bottomCoverDateLabel.text = item.watchedOn
//        self.userNameLabel.text = item.authorId
        
//        self.likeBtn.isLike
//        private let likeCntLabel = UILabel().then {
//            $0.font = .fonts(.body)
//            $0.textColor = Gen.Colors.gray03.color
//        }
        
       
        if self.currentIndex != -1 {
            if currentIndex > infoData.index {
                self.feedbackGenerator?.impactOccurred()
                self.mainContentsView.alpha = 0
                UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseIn, animations: {
                    self.mainContentsView.frame = CGRect(x: self.mainContentsView.frame.origin.x + 25, y: self.mainContentsView.frame.origin.y, width: self.mainContentsView.frame.width, height: self.mainContentsView.frame.height)
                    self.mainContentsView.alpha = 1
                })
            } else if currentIndex < infoData.index {
                self.feedbackGenerator?.impactOccurred()
                self.mainContentsView.alpha = 0
                UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseIn, animations: {
                    self.mainContentsView.frame = CGRect(x: self.mainContentsView.frame.origin.x - 25, y: self.mainContentsView.frame.origin.y, width: self.mainContentsView.frame.width, height: self.mainContentsView.frame.height)
                    self.mainContentsView.alpha = 1
                })
            }
        }
        self.currentIndex = infoData.index // 위치가 별로긴 한데.. 애니메이션때문에 우선 여기에 넣고 개선해보자.. showCover 라는 메서드에서 바꿔주는걸 파악하고있지 않으면 알 수가 없음...
        
    }
    
    private func makeNavigationItems() {
        self.userImageView.snp.makeConstraints {
            $0.width.height.equalTo(30)
        }
        self.userImageView.contentMode = .scaleAspectFit
        let userImageItem = UIBarButtonItem.init(customView: self.userImageView)
        let negativeSpacer1 = UIBarButtonItem.init(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        let negativeSpacer2 = UIBarButtonItem.init(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        let userNameItem = UIBarButtonItem.init(customView: self.userNameLabel)
        let leftItems: [UIBarButtonItem] = [userImageItem, userNameItem, negativeSpacer1, negativeSpacer2]
        
        let closeItem = UIBarButtonItem.init(customView: self.closeBtn)
        let moreItem = UIBarButtonItem.init(customView: self.moreBtn)
        let rightItems: [UIBarButtonItem] = [closeItem, moreItem]
        
        self.navigationController?.navigationBar.topItem?.leftBarButtonItems = leftItems
        self.navigationController?.navigationBar.topItem?.rightBarButtonItems = rightItems
        
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.navigationBar.tintColor = .white
    }
    
    private func showPhoto(infoData: CommunityReactor.DetailInfo) {
        guard let item = infoData.archiveInfo.images?[infoData.innerIndex-1] else { return }
        self.topCoverContentsView.isHidden = true
        self.bottomCoverContentsView.isHidden = true
        self.topPhotoContentsView.isHidden = false
        self.bottomPhotoContentsView.isHidden = false
        
        self.photoImageView.kf.setImage(with: URL(string: item.image),
                                        placeholder: nil,
                                        options: [.cacheMemoryOnly]) { [weak self] _ in
            self?.photoImageView.fadeIn(duration: 0.1,
                                        completeHandler: nil)
        }
        self.photoContentsLabel.text = item.review
        self.mainBackgroundView.backgroundColor = item.backgroundColor.colorWithHexString()
        
    }
    
    private func getProgressPercent(totalPageCnt: Int, currentIndex: Int) -> CGFloat {
        if totalPageCnt == currentIndex + 1 {
            return 1
        } else {
            return CGFloat(CGFloat((currentIndex + 1)) / CGFloat(totalPageCnt))
        }
    }
    
    private func setGenerator() {
        self.feedbackGenerator = UIImpactFeedbackGenerator(style: .soft)
        self.feedbackGenerator?.prepare()
    }
    

    
    @objc private func leftClicked() {
        print("leftClicked")
        self.reactor?.action.onNext(.showBeforePage)
    }
    
    @objc private func rightClicked() {
        print("rightClicked")
        self.reactor?.action.onNext(.showNextPage)
    }
    
    @objc private func moreClicked() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let reportAction: UIAlertAction = UIAlertAction(title: "부적절한 콘텐츠로 신고하기", style: .default) { [weak self] _ in
            self?.reactor?.action.onNext(.showReportPage)
        }
        reportAction.setValue(Gen.Colors.errorRed.color, forKey: "titleTextColor")
        
        alert.view.tintColor = Gen.Colors.black.color
        alert.addAction(reportAction)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    @objc private func closeClicked() {
        self.dismiss(animated: true)
    }
    
    @objc private func handleSwipes(_ sender: UISwipeGestureRecognizer) {
        if sender.direction == .left {
            self.reactor?.action.onNext(.showNextUser)
        } else if sender.direction == .right {
            self.reactor?.action.onNext(.showBeforeUser)
        }
    }
    
    // MARK: func

}

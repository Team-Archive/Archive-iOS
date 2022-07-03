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

class CommunityDetailViewController: UIViewController, View, ActivityIndicatorable {
    
    // MARK: UI property
    
    private let mainBackgroundView = UIView().then {
        $0.backgroundColor = Gen.Colors.white.color
    }
    
    private let mainContentsView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private let topContentsView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private let bottomContentsView = BottomPaddingCoverView().then {
        $0.backgroundColor = Gen.Colors.white.color
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
    
    private let likeBtn = LikeButton().then {
        $0.backgroundColor = .clear
    }
    
    private let likeCntLabel = UILabel().then {
        $0.font = .fonts(.body)
        $0.textColor = Gen.Colors.gray03.color
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
        $0.backgroundColor = .red
    }
    
    // MARK: private property
    
    // MARK: property
    var disposeBag: DisposeBag = DisposeBag()
    
    // MARK: lifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        self.bottomCoverContentsView.addSubview(self.likeBtn)
        self.likeBtn.snp.makeConstraints {
            $0.trailing.equalTo(self.bottomCoverContentsView.snp.trailing).offset(-32)
            $0.width.equalTo(40)
            $0.height.equalTo(40)
            $0.centerY.equalTo(bottomCoverDateLabel.snp.centerY)
        }
        
        self.bottomContentsView.addSubview(self.likeCntLabel)
        self.likeCntLabel.snp.makeConstraints {
            $0.centerX.equalTo(likeBtn.snp.centerX)
            $0.top.equalTo(self.likeBtn.snp.bottom).offset(5)
        }
        
        self.topContentsView.addSubview(self.topPhotoContentsView)
        self.topPhotoContentsView.snp.makeConstraints {
            $0.edges.equalTo(self.topContentsView)
        }
        
        self.topPhotoContentsView.addSubview(self.photoImageView)
        self.photoImageView.snp.makeConstraints {
            $0.edges.equalTo(self.topPhotoContentsView)
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
            .asDriver(onErrorJustReturn: .init(archiveInfo: .init(archiveId: 0, authorId: 0, name: "", watchedOn: "", emotion: .fun, companions: nil, mainImage: "", images: nil), index: 0))
            .drive(onNext: { [weak self] data in
                if data.index == 0 {
                    self?.showCover(infoData: data)
                } else {
                    self?.showPhoto(infoData: data)
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
        
//        self.likeBtn.isLike
//        private let likeCntLabel = UILabel().then {
//            $0.font = .fonts(.body)
//            $0.textColor = Gen.Colors.gray03.color
//        }
        
    }
    
    private func showPhoto(infoData: CommunityReactor.DetailInfo) {
        guard let item = infoData.archiveInfo.images?[infoData.index-1] else { return }
        self.topCoverContentsView.isHidden = true
        self.bottomCoverContentsView.isHidden = true
        self.topPhotoContentsView.isHidden = false
        self.bottomPhotoContentsView.isHidden = false
        
        self.photoImageView.kf.setImage(with: URL(string: item.image),
                                            placeholder: nil,
                                            options: [.cacheMemoryOnly],
                                            completionHandler: nil)
        self.photoContentsLabel.text = item.review
        self.mainBackgroundView.backgroundColor = item.backgroundColor.colorWithHexString()
        
    }
    
    @objc private func leftClicked() {
        print("leftClicked")
        self.reactor?.action.onNext(.showBeforePage)
    }
    
    @objc private func rightClicked() {
        print("rightClicked")
        self.reactor?.action.onNext(.showNextPage)
    }
    
    // MARK: func

}

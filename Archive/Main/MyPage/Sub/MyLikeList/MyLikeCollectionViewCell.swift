//
//  MyLikeCollectionViewCell.swift
//  Archive
//
//  Created by hanwe on 2022/07/31.
//

import UIKit
import SnapKit
import Kingfisher
import RxSwift
import RxCocoa
import Then

@objc protocol MyLikeCollectionViewCellDelegate: AnyObject {
    @objc optional func likeCanceled(archiveId: Int)
}

class MyLikeCollectionViewCell: UICollectionViewCell, ClassIdentifiable {
    
    // MARK: UI property
    
    private let mainBackgroundView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private let mainContentsView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private let cardView = UIView().then {
        $0.backgroundColor = Gen.Colors.white.color
        $0.layer.cornerRadius = 8
        $0.layer.masksToBounds = true
    }
    
    private let thumbnailImageView = UIImageView().then {
        $0.backgroundColor = .clear
    }
    
    private let emotionCoverImageView = UIImageView().then {
        $0.backgroundColor = .clear
    }
    
    private let userImageView = UIImageView().then {
        $0.backgroundColor = .clear
        $0.image = Gen.Images.userImagePlaceHolder.image
        $0.layer.cornerRadius = 15
        $0.layer.masksToBounds = true
    }
    
    private let userNicknameLabel = UILabel().then {
        $0.font = .fonts(.button2)
        $0.textColor = Gen.Colors.white.color
    }
    
    private let cardBottomView = UIView().then {
        $0.backgroundColor = Gen.Colors.white.color
    }
    
    private let archiveTitleLabel = UILabel().then {
        $0.font = .fonts(.header3)
        $0.textColor = Gen.Colors.black.color
        $0.numberOfLines = 2
    }
    
    private let dateLabel = UILabel().then {
        $0.font = .fonts(.subTitle)
        $0.textColor = Gen.Colors.gray03.color
    }
    
    let likeBtn = LikeButton().then {
        $0.backgroundColor = .clear
        $0.isLike = true
    }
    
    private let likeCntLabel = UILabel().then {
        $0.font = .fonts(.body)
        $0.textColor = Gen.Colors.gray03.color
    }
    
    private let emotionContainerView = UIView().then {
        $0.layer.cornerRadius = 10
        $0.backgroundColor = Gen.Colors.whiteOpacity70.color
    }
    
    private lazy var emotionImageView = UIImageView().then {
        $0.backgroundColor = .clear
    }
    
    private lazy var emotionTitleLabel = UILabel().then {
        $0.font = .fonts(.subTitle)
        $0.textColor = Gen.Colors.black.color
    }
    
    // MARK: private property
    
    private let disposeBag = DisposeBag()
    private var isLike: Bool = false // 화면에서 보여지는 버튼의 좋아요가 아닌 진짜 나의 상태값임
    
    // MARK: internal property
    
    var infoData: PublicArchive? {
        didSet {
            guard let info = self.infoData else { return }
            DispatchQueue.main.async { [weak self] in
                if let thumbnailUrl = URL(string: info.mainImage) {
                    self?.thumbnailImageView.kf.setImage(with: thumbnailUrl)
                }
                
                self?.emotionCoverImageView.image = info.emotion.coverAlphaImage
                if let userImageUrl = URL(string: info.authorProfileImage) {
                    self?.userImageView.kf.setImage(with: userImageUrl, placeholder: Gen.Images.userImagePlaceHolder.image)
                } else {
                    self?.userImageView.image = Gen.Images.userImagePlaceHolder.image
                }
                
                self?.userNicknameLabel.text = info.authorNickname
                self?.archiveTitleLabel.text = info.archiveName
                self?.dateLabel.text = info.watchedOn
                self?.likeCntLabel.text = info.likeCount.likeCntToArchiveLikeCnt
                self?.emotionImageView.image = info.emotion.typeImage
                self?.emotionTitleLabel.text = info.emotion.localizationTitle
                switch info.coverType {
                case .cover:
                    self?.emotionContainerView.isHidden = true
                    self?.emotionCoverImageView.isHidden = false
                    self?.thumbnailImageView.contentMode = .scaleToFill
                case .image:
                    self?.emotionCoverImageView.isHidden = true
                    self?.emotionContainerView.isHidden = false
                    self?.thumbnailImageView.contentMode = .scaleAspectFill
                }
            }
        }
    }
    
    weak var delegate: MyLikeCollectionViewCellDelegate?
    
    // MARK: lifeCycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        bind()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
        bind()
    }
    
    // MARK: private function
    
    private func setup() {
        
        self.addSubview(mainBackgroundView)
        self.mainBackgroundView.snp.makeConstraints {
            $0.edges.equalTo(self)
        }
        
        self.mainBackgroundView.addSubview(self.mainContentsView)
        self.mainContentsView.snp.makeConstraints {
            $0.edges.equalTo(self.mainBackgroundView)
        }
        
        self.mainContentsView.addSubview(self.cardView)
        self.cardView.snp.makeConstraints {
            $0.top.equalTo(self.mainContentsView.snp.top)
            $0.bottom.equalTo(self.mainContentsView.snp.bottom)
            $0.leading.equalTo(self.mainContentsView.snp.leading).offset(32)
            $0.trailing.equalTo(self.mainContentsView.snp.trailing).offset(-32)
        }
        
        self.cardView.addSubview(self.thumbnailImageView)
        self.thumbnailImageView.snp.makeConstraints {
            $0.top.equalTo(self.cardView.snp.top)
            $0.leading.equalTo(self.cardView.snp.leading)
            $0.trailing.equalTo(self.cardView.snp.trailing)
            $0.height.equalTo(self.cardView.snp.width)
        }
        
        self.cardView.addSubview(self.emotionCoverImageView)
        self.emotionCoverImageView.snp.makeConstraints {
            $0.top.equalTo(self.cardView.snp.top)
            $0.leading.equalTo(self.cardView.snp.leading)
            $0.trailing.equalTo(self.cardView.snp.trailing)
            $0.height.equalTo(self.cardView.snp.width)
        }
        
        self.cardView.addSubview(self.userImageView)
        self.userImageView.snp.makeConstraints {
            $0.width.equalTo(30)
            $0.height.equalTo(30)
            $0.top.equalTo(self.cardView.snp.top).offset(16)
            $0.leading.equalTo(self.cardView.snp.leading).offset(16)
        }
        
        self.cardView.addSubview(self.userNicknameLabel)
        self.userNicknameLabel.snp.makeConstraints {
            $0.centerY.equalTo(self.userImageView.snp.centerY)
            $0.leading.equalTo(self.userImageView.snp.trailing).offset(8)
            $0.trailing.equalTo(self.cardView.snp.trailing).offset(2)
        }
        
        
        self.cardView.addSubview(self.cardBottomView)
        self.cardBottomView.snp.makeConstraints {
            $0.leading.equalTo(self.cardView.snp.leading)
            $0.trailing.equalTo(self.cardView.snp.trailing)
            $0.top.equalTo(self.emotionCoverImageView.snp.bottom)
            $0.height.equalTo(self.cardView.snp.height).multipliedBy(0.2)
        }
        
        self.cardBottomView.addSubview(self.archiveTitleLabel)
        self.archiveTitleLabel.snp.makeConstraints {
            $0.top.equalTo(self.cardBottomView.snp.top).offset(10)
            $0.leading.equalTo(self.cardBottomView.snp.leading)
        }

        self.cardBottomView.addSubview(self.dateLabel)
        self.dateLabel.snp.makeConstraints {
            $0.top.equalTo(self.archiveTitleLabel.snp.bottom).offset(5)
            $0.leading.equalTo(self.cardView.snp.leading)
        }

        self.cardBottomView.addSubview(self.likeBtn)
        self.likeBtn.snp.makeConstraints {
            $0.trailing.equalTo(self.cardBottomView.snp.trailing).offset(-5)
            $0.top.equalTo(self.cardBottomView.snp.top).offset(5)
            $0.width.equalTo(30)
            $0.height.equalTo(30)
            $0.leading.equalTo(self.archiveTitleLabel.snp.trailing).offset(8)
        }

        self.cardBottomView.addSubview(self.likeCntLabel)
        self.likeCntLabel.snp.makeConstraints {
            $0.centerX.equalTo(self.likeBtn.snp.centerX)
            $0.top.equalTo(self.likeBtn.snp.bottom).offset(-5)
        }
        
        self.cardView.addSubview(self.emotionContainerView)
        self.emotionContainerView.snp.makeConstraints {
            $0.bottom.trailing.equalTo(self.thumbnailImageView).offset(-12)
        }
        
        emotionContainerView.addSubview(emotionImageView)
        emotionImageView.snp.makeConstraints {
            $0.width.equalTo(24)
            $0.height.equalTo(24)
            $0.leading.equalTo(self.emotionContainerView).offset(8)
            $0.top.equalTo(self.emotionContainerView).offset(6)
            $0.bottom.equalTo(self.emotionContainerView).offset(-6)
        }
        
        emotionContainerView.addSubview(emotionTitleLabel)
        emotionTitleLabel.snp.makeConstraints {
            $0.centerY.equalTo(emotionImageView.snp.centerY)
            $0.leading.equalTo(emotionImageView.snp.trailing).offset(8)
            $0.trailing.equalTo(emotionContainerView.snp.trailing).offset(-8)
        }
    }
    
    private func bind() {
        self.likeBtn.rx.likeClicked
            .subscribe(onNext: { [weak self] _ in
                guard let archiveId = self?.infoData?.archiveId else { return }
                LikeManager.shared.likeCancel(id: "\(archiveId)")
                self?.delegate?.likeCanceled?(archiveId: archiveId)
            })
            .disposed(by: self.disposeBag)
    }
    
    // MARK: internal function
    
}

class MyLikeCollectionViewCellDelegateProxy: DelegateProxy<MyLikeCollectionViewCell, MyLikeCollectionViewCellDelegate>, DelegateProxyType, MyLikeCollectionViewCellDelegate {
    
    
    static func currentDelegate(for object: MyLikeCollectionViewCell) -> MyLikeCollectionViewCellDelegate? {
        return object.delegate
    }
    
    static func setCurrentDelegate(_ delegate: MyLikeCollectionViewCellDelegate?, to object: MyLikeCollectionViewCell) {
        object.delegate = delegate
    }
    
    static func registerKnownImplementations() {
        self.register { (view) -> MyLikeCollectionViewCellDelegateProxy in
            MyLikeCollectionViewCellDelegateProxy(parentObject: view, delegateProxy: self)
        }
    }
}

extension Reactive where Base: MyLikeCollectionViewCell {
    var delegate: DelegateProxy<MyLikeCollectionViewCell, MyLikeCollectionViewCellDelegate> {
        return MyLikeCollectionViewCellDelegateProxy.proxy(for: self.base)
    }
    
    var likeCanceled: Observable<Int> {
        return delegate.methodInvoked(#selector(MyLikeCollectionViewCellDelegate.likeCanceled(archiveId:)))
            .map { result in
                return result[0] as? Int ?? 0
            }
    }
}

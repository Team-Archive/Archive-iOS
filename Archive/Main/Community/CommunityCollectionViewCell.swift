//
//  CommunityCollectionViewCell.swift
//  Archive
//
//  Created by hanwe on 2022/06/25.
//

import UIKit
import SnapKit
import Kingfisher
import RxSwift
import RxCocoa
import Then

class CommunityCollectionViewCell: UICollectionViewCell, ClassIdentifiable {
    
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
    
    private let likeBtn = LikeButton().then {
        $0.backgroundColor = .clear
    }
    
    private let likeCntLabel = UILabel().then {
        $0.font = .fonts(.body)
        $0.textColor = Gen.Colors.gray03.color
    }
    
    // MARK: private property
    
    private let disposeBag = DisposeBag()
    
    // MARK: internal property
    
    var infoData: PublicArchive? {
        didSet {
            guard let info = self.infoData else { return }
            DispatchQueue.main.async { [weak self] in
                if let thumbnailUrl = URL(string: info.mainImage) {
                    self?.thumbnailImageView.kf.setImage(with: thumbnailUrl,
                                                         completionHandler: { [weak self] _ in
                        self?.thumbnailImageView.fadeIn(duration: 0.1,
                                                        completeHandler: nil)
                    })
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
                let likeCnt: Int = {
                    var cnt = info.likeCount
                    if LikeManager.shared.likeList.contains("\(info.archiveId)") {
                        cnt += 1
                    }
                    return cnt
                }()
                self?.likeCntLabel.text = likeCnt.likeCntToArchiveLikeCnt
            }
        }
    }
    
    weak var reactor: CommunityReactor?
    var index: Int = -1
    var isLike: Bool = false {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.refreshLikeUI()
            }
        }
    }
    
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
            $0.bottom.equalTo(self.cardView.snp.bottom)
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
    }
    
    private func bind() {
        self.likeBtn.rx.likeClicked
            .subscribe(onNext: { [weak self] isLike in
                if isLike {
                    LikeManager.shared.like(id: "\(self?.infoData?.archiveId ?? -1)")
                } else {
                    LikeManager.shared.likeCancel(id: "\(self?.infoData?.archiveId ?? -1)")
                }
            })
            .disposed(by: self.disposeBag)
    }
    
    private func refreshLikeUI() {
        self.likeBtn.isLike = self.isLike
    }
    
    // MARK: internal function
    
}

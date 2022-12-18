//
//  TicketCollectionViewCell.swift
//  Archive
//
//  Created by TTOzzi on 2021/10/30.
//

import UIKit
import SnapKit
import Kingfisher
import Then

final class TicketCollectionViewCell: UICollectionViewCell, ReuseIdentifiable {
    
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()
    private lazy var imageContentView: TicketImageContentView = {
        let view = TicketImageContentView()
        return view
    }()
    
    private lazy var mainImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()

    
    private lazy var coverImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    private lazy var descriptionView: TicketDescriptionContentView = {
        let view = TicketDescriptionContentView()
        return view
    }()
    
    private lazy var emotionImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    private lazy var emotionTitleLabel: UILabel = {
        let label: UILabel = UILabel()
        label.font = .fonts(.subTitle)
        label.textColor = Gen.Colors.white.color
        return label
    }()
    
    private lazy var lockImageView = UIImageView().then {
        $0.backgroundColor = .clear
    }
    
    var infoData: ArchiveInfo? {
        didSet {
            guard let info = self.infoData else { return }
            DispatchQueue.main.async { [weak self] in
                self?.imageContentView.bgColor = info.emotion.color
                self?.coverImageView.image = info.emotion.coverAlphaImage
                self?.emotionImageView.image = info.emotion.preImage
                self?.emotionTitleLabel.text = info.emotion.localizationTitle
                self?.imageContentView.setNeedsDisplay()
                self?.mainImageView.kf.setImage(with: URL(string: info.mainImageUrl),
                                                      placeholder: nil,
                                                      options: [.cacheMemoryOnly],
                                                      completionHandler: nil)
                self?.descriptionView.titleLabel.text = info.archiveName
                self?.descriptionView.dateLabel.text = info.watchedOn
                self?.descriptionView.setLikeCount(info.likeCount)
                if info.isPublic {
                    self?.lockImageView.image = nil
                } else {
                    self?.lockImageView.image = Gen.Images.lock.image
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupAttributes()
        setupLayouts()
    }
    
    private func setupAttributes() {
        layer.backgroundColor = UIColor.clear.cgColor
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2.0)
        layer.shadowRadius = 10.0
        layer.shadowOpacity = 0.4
        layer.masksToBounds = false
    }
    
    private func setupLayouts() {
        contentView.addSubview(contentStackView)
        contentStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        contentStackView.addArrangedSubview(imageContentView)
        imageContentView.snp.makeConstraints {
            $0.width.equalTo(imageContentView.snp.height).multipliedBy(0.75)
        }
        imageContentView.addSubview(mainImageView)
        mainImageView.snp.makeConstraints {
            $0.width.equalTo(mainImageView.snp.height)
            $0.leading.trailing.centerY.equalToSuperview()
        }
        imageContentView.addSubview(coverImageView)
        coverImageView.snp.makeConstraints {
            $0.width.equalTo(coverImageView.snp.height)
            $0.leading.trailing.centerY.equalToSuperview()
        }
        contentStackView.addArrangedSubview(descriptionView)
        descriptionView.snp.makeConstraints {
            $0.height.equalTo(imageContentView.snp.height).multipliedBy(0.3)
        }
        descriptionView.setLayout()
        
        imageContentView.addSubview(emotionImageView)
        emotionImageView.snp.makeConstraints {
            $0.width.equalTo(24)
            $0.height.equalTo(24)
            $0.top.equalTo(imageContentView.snp.top).offset(20)
            $0.leading.equalTo(imageContentView.snp.leading).offset(20)
        }
        
        imageContentView.addSubview(emotionTitleLabel)
        emotionTitleLabel.snp.makeConstraints {
            $0.centerY.equalTo(emotionImageView.snp.centerY)
            $0.leading.equalTo(emotionImageView.snp.trailing).offset(8)
        }
        
        imageContentView.addSubview(lockImageView)
        lockImageView.snp.makeConstraints {
            $0.top.equalTo(self.imageContentView).offset(20)
            $0.trailing.equalTo(self.imageContentView).offset(-20)
            $0.width.height.equalTo(24)
        }
    }
}

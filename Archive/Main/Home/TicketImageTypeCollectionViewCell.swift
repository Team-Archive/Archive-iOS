//
//  TicketImageTypeCollectionViewCell.swift
//  Archive
//
//  Created by hanwe on 2023/01/06.
//

import UIKit
import SnapKit
import Kingfisher
import Then

final class TicketImageTypeCollectionViewCell: UICollectionViewCell, ReuseIdentifiable {
    
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()
    
    private lazy var imageContentView: TicketImageContentView = {
        let view = TicketImageContentView()
        view.layer.masksToBounds = true
        view.clipsToBounds = true
        return view
    }()
    
    private let mainImageContainerView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private lazy var mainImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    private lazy var descriptionView: TicketDescriptionContentView = {
        let view = TicketDescriptionContentView()
        return view
    }()
    
    private let emotionContainerView = UIView().then {
        $0.layer.cornerRadius = 10
        $0.backgroundColor = Gen.Colors.whiteOpacity70.color
    }
    
    private lazy var emotionImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    private lazy var emotionTitleLabel: UILabel = {
        let label: UILabel = UILabel()
        label.font = .fonts(.subTitle)
        label.textColor = Gen.Colors.black.color
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
                self?.emotionImageView.image = info.emotion.typeImage
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAttributes()
        setupLayouts()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        self.imageContentView.addSubview(self.mainImageContainerView)
        self.mainImageContainerView.snp.makeConstraints {
            $0.edges.equalTo(self.imageContentView)
        }
        mainImageContainerView.addSubview(mainImageView)
        mainImageView.snp.makeConstraints {
            $0.edges.equalTo(self)
        }
        contentStackView.addArrangedSubview(descriptionView)
        descriptionView.snp.makeConstraints {
            $0.height.equalTo(imageContentView.snp.height).multipliedBy(0.3)
        }
        descriptionView.setLayout()
        
        imageContentView.addSubview(self.emotionContainerView)
        self.emotionContainerView.snp.makeConstraints {
            $0.top.leading.equalTo(self.imageContentView).offset(12)
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
        
        imageContentView.addSubview(lockImageView)
        lockImageView.snp.makeConstraints {
            $0.top.equalTo(self.imageContentView).offset(20)
            $0.trailing.equalTo(self.imageContentView).offset(-20)
            $0.width.height.equalTo(24)
        }
    }
}

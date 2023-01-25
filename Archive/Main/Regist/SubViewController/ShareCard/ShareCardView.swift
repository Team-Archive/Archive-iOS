//
//  ShareCardView.swift
//  Archive
//
//  Created by hanwe on 2021/11/17.
//

import UIKit
import SnapKit
import Then

class ShareCardView: UIView, NibIdentifiable {
    // MARK: IBOutlet
    
    @IBOutlet weak var mainContainerView: UIView!

    // MARK: private property
    
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()
    private lazy var imageContentView: TicketImageContentView = {
        let view = TicketImageContentView()
        return view
    }()
    
    
    // cover
    private let coverTypeContainerView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private lazy var mainImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()

    
    private lazy var coverImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    // full image
    
    private let fullTypeContainerView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private let fullTypeMainImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
    }
    
    private let fullTypeEmotionContainerView = UIView().then {
        $0.layer.cornerRadius = 10
        $0.backgroundColor = Gen.Colors.whiteOpacity70.color
    }
    
    private lazy var fullTypeEmotionImageView = UIImageView().then {
        $0.backgroundColor = .clear
    }
    
    private lazy var fullTypeEmotionTitleLabel = UILabel().then {
        $0.font = .fonts(.subTitle)
        $0.textColor = Gen.Colors.black.color
    }
    
    
    // end
    
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

    // MARK: internal property

    class func instance() -> ShareCardView? {
        return nib.instantiate(withOwner: nil, options: nil).first as? ShareCardView
    }

    var topBackgroundColor: UIColor = .clear
    var bottomBackgroundColor: UIColor = .clear

    // MARK: lifeCycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupAttributes()
        setupLayouts()
    }

    // MARK: private function
    
    private func setupAttributes() {
        layer.backgroundColor = UIColor.clear.cgColor
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2.0)
        layer.shadowRadius = 10.0
        layer.shadowOpacity = 0.4
        layer.masksToBounds = false
    }
    
    private func setupLayouts() {
        mainContainerView.addSubview(contentStackView)
        contentStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        contentStackView.addArrangedSubview(imageContentView)
        imageContentView.snp.makeConstraints {
            $0.width.equalTo(imageContentView.snp.height).multipliedBy(0.75)
        }
        
        self.imageContentView.addSubview(self.coverTypeContainerView)
        self.coverTypeContainerView.snp.makeConstraints {
            $0.edges.equalTo(self.imageContentView)
        }
        
        
        coverTypeContainerView.addSubview(mainImageView)
        mainImageView.snp.makeConstraints {
            $0.width.equalTo(mainImageView.snp.height)
            $0.leading.trailing.centerY.equalToSuperview()
        }
        coverTypeContainerView.addSubview(coverImageView)
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
            $0.top.equalTo(coverTypeContainerView.snp.top).offset(20)
            $0.leading.equalTo(coverTypeContainerView.snp.leading).offset(20)
        }
        
        imageContentView.addSubview(emotionTitleLabel)
        emotionTitleLabel.snp.makeConstraints {
            $0.centerY.equalTo(emotionImageView.snp.centerY)
            $0.leading.equalTo(emotionImageView.snp.trailing).offset(8)
        }
        
        self.imageContentView.addSubview(self.fullTypeContainerView)
        self.fullTypeContainerView.snp.makeConstraints {
            $0.edges.equalTo(self.imageContentView)
        }
        
        self.fullTypeContainerView.addSubview(self.fullTypeMainImageView)
        self.fullTypeMainImageView.snp.makeConstraints {
            $0.edges.equalTo(self.fullTypeContainerView)
        }
        
        fullTypeContainerView.addSubview(self.fullTypeEmotionContainerView)
        self.fullTypeEmotionContainerView.snp.makeConstraints {
            $0.leading.top.equalTo(self.fullTypeContainerView).offset(12)
        }
        
        fullTypeEmotionContainerView.addSubview(fullTypeEmotionImageView)
        fullTypeEmotionImageView.snp.makeConstraints {
            $0.width.equalTo(24)
            $0.height.equalTo(24)
            $0.leading.equalTo(self.fullTypeEmotionContainerView).offset(8)
            $0.top.equalTo(self.fullTypeEmotionContainerView).offset(6)
            $0.bottom.equalTo(self.fullTypeEmotionContainerView).offset(-6)
        }
        
        fullTypeEmotionContainerView.addSubview(fullTypeEmotionTitleLabel)
        fullTypeEmotionTitleLabel.snp.makeConstraints {
            $0.centerY.equalTo(fullTypeEmotionImageView.snp.centerY)
            $0.leading.equalTo(fullTypeEmotionImageView.snp.trailing).offset(8)
            $0.trailing.equalTo(fullTypeEmotionContainerView.snp.trailing).offset(-8)
        }
    }

    // MARK: internal function
    
    func setInfoData(emotion: Emotion, thumbnailImage: UIImage, eventName: String, date: String, coverType: CoverType) {
        self.topBackgroundColor = emotion.darkenColor
        self.bottomBackgroundColor = emotion.color
        self.imageContentView.bgColor = emotion.color
        self.coverImageView.image = emotion.coverAlphaImage
        self.emotionImageView.image = emotion.preImage
        self.emotionTitleLabel.text = emotion.localizationTitle
        self.coverTypeContainerView.backgroundColor = emotion.color
        self.mainImageView.image = thumbnailImage
        self.descriptionView.titleLabel.text = eventName
        self.descriptionView.dateLabel.text = date
        self.fullTypeMainImageView.image = thumbnailImage
        self.fullTypeEmotionImageView.image = emotion.typeImage
        self.fullTypeEmotionTitleLabel.text = emotion.localizationTitle
        
        switch coverType {
        case .cover:
            self.fullTypeContainerView.isHidden = true
            self.coverTypeContainerView.isHidden = false
        case .image:
            self.fullTypeContainerView.isHidden = false
            self.coverTypeContainerView.isHidden = true
        }
    }
    
}

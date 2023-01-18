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
            $0.height.equalTo(coverTypeContainerView.snp.height).multipliedBy(0.3)
        }
        descriptionView.setLayout()
        
        coverTypeContainerView.addSubview(emotionImageView)
        emotionImageView.snp.makeConstraints {
            $0.width.equalTo(24)
            $0.height.equalTo(24)
            $0.top.equalTo(coverTypeContainerView.snp.top).offset(20)
            $0.leading.equalTo(coverTypeContainerView.snp.leading).offset(20)
        }
        
        coverTypeContainerView.addSubview(emotionTitleLabel)
        emotionTitleLabel.snp.makeConstraints {
            $0.centerY.equalTo(emotionImageView.snp.centerY)
            $0.leading.equalTo(emotionImageView.snp.trailing).offset(8)
        }
    }

    // MARK: internal function
    
    func setInfoData(emotion: Emotion, thumbnailImage: UIImage, eventName: String, date: String) {
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
    }
    
}

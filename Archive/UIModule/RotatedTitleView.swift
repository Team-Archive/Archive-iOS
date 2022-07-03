//
//  RotatedTitleView.swift
//  Archive
//
//  Created by hanwe on 2022/07/04.
//

import UIKit
import SnapKit
import Then

class RotatedTitleView: UIView {

    // MARK: UI property
    
    private let containerView = UIView().then {
        $0.backgroundColor = Gen.Colors.white.color
    }
    
    private let emotionView = UIImageView().then {
        $0.backgroundColor = .clear
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .fonts(.subTitle)
        $0.textColor = Gen.Colors.black.color
    }
    
    // MARK: private property
    
    // MARK: internal property
    
    var name: String = "" {
        didSet {
            self.titleLabel.text = self.name
        }
    }
    var emotion: Emotion = .fun {
        didSet {
            self.emotionView.image = self.emotion.typeImage
        }
    }
    
    // MARK: lifeCycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: private function
    
    private func setup() {
        self.addSubview(self.containerView)
        self.containerView.snp.makeConstraints {
            $0.edges.equalTo(self)
        }
        
        
        self.containerView.addSubview(emotionView)
        emotionView.snp.makeConstraints {
            $0.leading.equalTo(self.containerView.snp.leading).offset(40)
            $0.centerY.equalTo(self.containerView.snp.centerY).offset(0)
            $0.width.equalTo(20)
            $0.height.equalTo(20)
        }
        
        self.containerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(emotionView.snp.trailing).offset(10)
            $0.centerY.equalTo(self.containerView.snp.centerY).offset(0)
            $0.trailing.equalTo(self.containerView.snp.trailing).offset(-40)
        }
        
        self.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)
    }
    
    // MARK: function
    
    func getRotatedViewOffset() -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: UIFont.fonts(.subTitle)]
        return -(((self.name as NSString).size(withAttributes: fontAttributes).width + 110)/2)
    }
    
    

}

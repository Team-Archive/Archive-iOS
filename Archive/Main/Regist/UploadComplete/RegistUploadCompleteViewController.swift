//
//  RegistUploadCompleteViewController.swift
//  Archive
//
//  Created by hanwe on 2022/08/28.
//

import UIKit
import Then
import SnapKit
import RxCocoa
import RxSwift
import ReactorKit

class RegistUploadCompleteViewController: UIViewController, View {
    
    // MARK: UI Property
    
    private let mainBackgroundView = UIView().then {
        $0.backgroundColor = Gen.Colors.white.color
    }
    
    private let scrollContainerView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private let scrollView = UIScrollView().then {
        $0.backgroundColor = .clear
    }
    
    private let mainContentsView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .fonts(.header2)
        $0.textColor = Gen.Colors.gray01.color
        $0.numberOfLines = 2
//        $0.text = 이번 달에 2개의 전시를\n기록하셨네요!
        $0.textAlignment = .center
    }
    
    private let subTitleLabel = UILabel().then {
        $0.font = .fonts(.subTitle)
        $0.textColor = Gen.Colors.gray01.color
        $0.numberOfLines = 1
        $0.text = "기록한 아카이브를 공유해보세요."
        $0.textAlignment = .center
    }
    
    private let buttonContainerView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private lazy var shareInstagramBtn = UIButton().then {
        $0.imageView?.image = Gen.Images.instaShare.image
    }
    
    private lazy var saveToAlbumBtn = UIButton().then {
        $0.imageView?.image = Gen.Images.download.image
    }
    
    private let lineImageView = UIImageView().then {
        $0.image = Gen.Images.line.image
    }
    
    private let ticketImageView = UIImageView().then {
        $0.image = Gen.Images.ticket.image
    }
    
    // MARK: private property
    
    // MARK: internal property
    
    var disposeBag: DisposeBag = DisposeBag()
    
    // MARK: life cycle
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init(reactor: RegistReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    override func loadView() {
        super.loadView()
        self.view.addSubview(self.mainBackgroundView)
        self.mainBackgroundView.snp.makeConstraints {
            $0.edges.equalTo(self.view)
        }
        
        let safeGuide = self.view.safeAreaLayoutGuide
        
        self.view.addSubview(self.scrollContainerView)
        self.scrollContainerView.snp.makeConstraints {
            $0.edges.equalTo(safeGuide)
        }
        
        self.scrollContainerView.addSubview(self.scrollView)
        self.scrollView.snp.makeConstraints {
            $0.edges.equalTo(self.scrollContainerView)
        }
        
        self.scrollView.addSubview(self.mainContentsView)
        self.mainContentsView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(self.scrollView)
        }
        
        self.mainContentsView.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints {
            $0.top.equalTo(self.mainContentsView).offset(14)
            $0.leading.trailing.equalTo(self.mainContentsView)
        }
        
        self.mainContentsView.addSubview(self.subTitleLabel)
        self.subTitleLabel.snp.makeConstraints {
            $0.top.equalTo(self.titleLabel.snp.bottom).offset(24)
            $0.leading.trailing.equalTo(self.mainContentsView)
        }
        
        self.mainContentsView.addSubview(self.buttonContainerView)
        self.buttonContainerView.snp.makeConstraints {
            $0.top.equalTo(self.subTitleLabel.snp.bottom).offset(28)
            $0.centerX.equalTo(self.mainContentsView)
        }
        
        self.buttonContainerView.addSubview(self.saveToAlbumBtn)
        self.saveToAlbumBtn.snp.makeConstraints {
            $0.top.leading.bottom.equalTo(self.buttonContainerView)
            $0.width.height.equalTo(56)
        }
        
        self.buttonContainerView.addSubview(self.shareInstagramBtn)
        self.shareInstagramBtn.snp.makeConstraints {
            $0.centerY.equalTo(self.saveToAlbumBtn)
            $0.leading.equalTo(self.saveToAlbumBtn.snp.trailing).offset(20)
            $0.trailing.equalTo(self.buttonContainerView)
        }
        
        self.mainContentsView.addSubview(self.lineImageView)
        self.lineImageView.snp.makeConstraints {
            $0.top.equalTo(self.buttonContainerView.snp.bottom).offset(55)
            $0.leading.trailing.equalTo(self.mainContentsView)
            $0.height.equalTo(1)
        }
        
        self.mainContentsView.addSubview(self.ticketImageView)
        self.ticketImageView.snp.makeConstraints {
            $0.top.equalTo(self.lineImageView.snp.bottom).offset(49)
            $0.centerY.equalTo(self.mainContentsView)
            $0.width.equalTo(175)
            $0.height.equalTo(294)
            $0.bottom.equalTo(self.mainContentsView.snp.bottom).offset(20)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    deinit {
        print("\(self) deinit")
    }
    
    func bind(reactor: RegistReactor) {
        
    }
    
    // MARK: private func
    
    // MARK: internal func
    
    
}

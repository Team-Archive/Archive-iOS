//
//  RegistViewController.swift
//  Archive
//
//  Created by Aaron Hanwe LEE on 2022/08/11.
//

import UIKit
import Then
import SnapKit
import RxCocoa
import RxSwift
import ReactorKit

class RegistViewController: UIViewController, View {
    
    // MARK: UI Property
    
    private let mainBackgroundView = UIView().then {
        $0.backgroundColor = Gen.Colors.white.color
    }
    
    private lazy var mainContentsView = HWFlipView(foregroundView: self.foregroundView, behindView: self.behindeView).then {
        $0.backgroundColor = .clear
    }
    
    // foregroundView
    
    private let foregroundView = UIView().then {
        $0.backgroundColor = Gen.Colors.white.color
    }
    
    private let foregroundScrollView = UIScrollView().then {
        $0.backgroundColor = .clear
    }
    
    private let foregroundContentsView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private lazy var topGradationView = UIImageView().then {
        $0.backgroundColor = .clear
        $0.image = Gen.Images.navigationGradation.image
    }
    
    private let foregroundBottomContentsView = UIView().then {
        $0.backgroundColor = .clear
    }
     
    private let foregroundBottomHelpTitleLabel = UILabel().then {
        $0.font = .fonts(.subTitle)
        $0.textColor = Gen.Colors.black.color
        $0.text = "무슨 전시를 감상했나요?"
    }
    
    private let foregroundBottomTitlePlaceHolderLabel = UILabel().then {
        $0.font = .fonts(.header2)
        $0.textColor = Gen.Colors.gray02.color
        $0.text = "전시명을 입력해주세요."
    }
    
    private let foregroundBottomTitleLabel = UILabel().then {
        $0.font = .fonts(.header2)
        $0.textColor = Gen.Colors.black.color
    }
    
    private let foregroundBottomUnderLineView = UIView().then {
        $0.backgroundColor = Gen.Colors.gray04.color
    }
    
    private let foregroundTopContentsView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    // step1
    
    private let foregroundTopStep1View = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private let foregroundTopPlaceHolderImgView = UIImageView().then {
        $0.image = Gen.Images.emptyTicket.image
    }
    
    
    
    private let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: UICollectionViewLayout()).then {
        $0.isPagingEnabled = true
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        let bottomPaddding = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.safeAreaInsets.bottom ?? 0
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - bottomPaddding)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        $0.collectionViewLayout = layout
    }
    
    // behindeView
    
    private let behindeView = UIView().then {
//        $0.backgroundColor = Gen.Colors.white.color
        $0.backgroundColor = .gray
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
        
        self.view.addSubview(self.mainContentsView)
        self.mainContentsView.snp.makeConstraints {
            $0.bottom.leading.trailing.equalTo(safeGuide)
            $0.top.equalTo(self.view)
        }
        
        self.foregroundView.addSubview(self.foregroundScrollView)
        self.foregroundScrollView.snp.makeConstraints {
            $0.edges.equalTo(self.foregroundView)
        }
        
        self.foregroundScrollView.addSubview(self.foregroundContentsView)
        self.foregroundContentsView.snp.makeConstraints {
            $0.edges.equalTo(self.foregroundScrollView).priority(750)
            $0.width.equalTo(self.foregroundScrollView).priority(1000)
            $0.height.equalTo(1500)
        }
        
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        let statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        self.foregroundView.addSubview(self.topGradationView)
        self.topGradationView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(self.foregroundView)
            $0.height.equalTo(statusBarHeight + (self.navigationController?.navigationBar.bounds.height ?? 0))
        }
        
//        private let  = UIView().then {
//            $0.backgroundColor = .clear
//        }
//
//        private lazy var topGradationView = UIImageView().then {
//            $0.backgroundColor = .clear
//            $0.image = Gen.Images.navigationGradation.image
//        }
//
//        private let foregroundBottomContentsView = UIView().then {
//            $0.backgroundColor = .clear
//        }
//
//        private let foregroundBottomHelpTitleLabel = UILabel().then {
//            $0.font = .fonts(.subTitle)
//            $0.textColor = Gen.Colors.black.color
//            $0.text = "무슨 전시를 감상했나요?"
//        }
//
//        private let foregroundBottomTitlePlaceHolderLabel = UILabel().then {
//            $0.font = .fonts(.header2)
//            $0.textColor = Gen.Colors.gray02.color
//            $0.text = "전시명을 입력해주세요."
//        }
//
//        private let foregroundBottomTitleLabel = UILabel().then {
//            $0.font = .fonts(.header2)
//            $0.textColor = Gen.Colors.black.color
//        }
//
//        private let foregroundBottomUnderLineView = UIView().then {
//            $0.backgroundColor = Gen.Colors.gray04.color
//        }
//
//        private let foregroundTopContentsView = UIView().then {
//            $0.backgroundColor = .clear
//        }
//
//        // step1
//
//        private let foregroundTopStep1View = UIView().then {
//            $0.backgroundColor = .clear
//        }
//
//        private let foregroundTopPlaceHolderImgView = UIImageView().then {
//            $0.image = Gen.Images.emptyTicket.image
//        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func bind(reactor: RegistReactor) {
        
    }
    
    // MARK: private func
    
    // MARK: internal func
    
    
}

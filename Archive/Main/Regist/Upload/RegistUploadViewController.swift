//
//  RegistUploadViewController.swift
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
import Lottie

class RegistUploadViewController: UIViewController, View {
    
    // MARK: UI Property
    
    private let mainBackgroundView = UIView().then {
        $0.backgroundColor = Gen.Colors.white.color
    }
    
    private let mainContentsView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private let contentsContainerView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private let lottieView = AnimationView().then {
        $0.backgroundColor = .clear
        $0.animation = Animation.named("Upload")
        $0.contentMode = .scaleAspectFit
        $0.loopMode = .loop
    }
    
    private let contentsLabel = UILabel().then {
        $0.font = .fonts(.header2)
        $0.textColor = Gen.Colors.gray01.color
        $0.numberOfLines = 2
        $0.text = "아카이브를\n보관 중입니다."
        $0.textAlignment = .center
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
            $0.edges.equalTo(safeGuide)
        }
        
        self.mainContentsView.addSubview(self.contentsContainerView)
        self.contentsContainerView.snp.makeConstraints {
            $0.center.equalTo(self.mainContentsView)
        }
        
        self.contentsContainerView.addSubview(self.lottieView)
        self.lottieView.snp.makeConstraints {
            $0.top.equalTo(self.contentsContainerView)
            $0.centerX.equalTo(self.contentsContainerView)
            $0.width.height.equalTo(215)
        }
        
        self.contentsContainerView.addSubview(self.contentsLabel)
        self.contentsLabel.snp.makeConstraints {
            $0.top.equalTo(self.lottieView.snp.bottom)
            $0.bottom.leading.trailing.equalTo(self.contentsContainerView)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.lottieView.play()
    }
    
    deinit {
        print("\(self) deinit")
    }
    
    func bind(reactor: RegistReactor) {
        
    }
    
    // MARK: private func
    
    // MARK: internal func
    
    func stopAnimation() {
        self.lottieView.stop()
    }
    
    
}

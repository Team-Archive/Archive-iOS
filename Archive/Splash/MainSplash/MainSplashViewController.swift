//
//  MainSplashViewController.swift
//  Archive
//
//  Created by hanwe on 2022/05/14.
//

import UIKit
import ReactorKit
import Then
import Lottie

class MainSplashViewController: UIViewController, View {
    
    // MARK: private ui property
    
    private let mainBackgroundView = UIView().then {
        $0.backgroundColor = Gen.Colors.black.color
    }
    
    private let mainContentsView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private let animationView = AnimationView().then {
        $0.backgroundColor = .clear
        $0.animation = Animation.named("Splash")
        $0.contentMode = .scaleAspectFit
        $0.loopMode = .playOnce
    }
    
    // MARK: private property
    
    // MARK: property
    var disposeBag: DisposeBag = DisposeBag()
    
    // MARK: lifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        play()
        self.reactor?.action.onNext(.autoLogin)
    }
    
    init(reactor: MainSplashReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
        setUp()
    }
    
    override func loadView() {
        super.loadView()
        self.view.addSubview(self.mainBackgroundView)
        self.mainBackgroundView.snp.makeConstraints {
            $0.edges.equalTo(self.view)
        }
        
        self.view.addSubview(self.mainContentsView)
        let safeGuide = self.view.safeAreaLayoutGuide
        self.mainContentsView.snp.makeConstraints {
            $0.edges.equalTo(safeGuide)
        }
        
        self.view.addSubview(self.animationView)
        self.animationView.snp.makeConstraints {
            $0.edges.equalTo(self.view)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(reactor: MainSplashReactor) {
        
    }
    
    deinit {
        print("\(self) deinit")
    }
    
    // MARK: private func
    
    private func setUp() {
        
    }
    
    private func play() {
        self.animationView.play(completion: { [weak self] _ in
            self?.reactor?.action.onNext(.setIsFinishAnimation)
        })
    }
    
    // MARK: func
    
    
    

}

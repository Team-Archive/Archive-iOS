//
//  MyPageViewController.swift
//  Archive
//
//  Created by hanwe on 2022/05/15.
//

import UIKit
import ReactorKit
import Then
import RxCocoa
import RxSwift

class MyPageViewController: UIViewController, View, ActivityIndicatorable {

    // MARK: private ui property
    
    private let mainBackgroundView = UIView().then {
        $0.backgroundColor = Gen.Colors.white.color
    }
    
    private let mainContentsView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private let topContentsContainerView = UIView().then {
//        $0.backgroundColor = Gen.Colors.white.color
        $0.backgroundColor = .brown
    }
    private let topContentsContainerViewHeight: CGFloat = 220
    
    private lazy var collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: UICollectionViewLayout()).then {
        $0.delaysContentTouches = false
        $0.contentInset = UIEdgeInsets(top: self.topContentsContainerViewHeight, left: 0, bottom: 0, right: 0)
        $0.alwaysBounceVertical = true
    }
    
    
    // MARK: private property
    
    // MARK: property
    var disposeBag: DisposeBag = DisposeBag()
    
    // MARK: lifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    init(reactor: MyPageReactor) {
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
        
        self.mainContentsView.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints {
            $0.edges.equalTo(self.mainContentsView)
        }
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: 100, height: 100)
        self.collectionView.collectionViewLayout = layout
        
        self.mainContentsView.addSubview(self.topContentsContainerView)
        self.topContentsContainerView.snp.makeConstraints {
            $0.top.equalTo(self.mainContentsView.snp.top)
            $0.leading.equalTo(self.mainContentsView.snp.leading)
            $0.trailing.equalTo(self.mainContentsView.snp.trailing)
            $0.height.equalTo(self.topContentsContainerViewHeight)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(reactor: MyPageReactor) {
        self.collectionView.rx.contentOffset
            .asDriver()
            .drive(onNext: { [weak self] offset in
                print("offset: \(offset.y)")
//                if offset.y >= 0 {
//
//                } else {
//
//                }
                guard let strongSelf = self else { return }
                let translation = strongSelf.collectionView.panGestureRecognizer.translation(in: strongSelf.collectionView.superview)
                if translation.y > 0 {
                    print("다운")
                } else {
                    print("업")
                }
            })
            .disposed(by: self.disposeBag)
    }
    
    deinit {
        print("\(self) deinit")
    }
    
    // MARK: private func
    
    private func setUp() {
        
    }
    
    // MARK: func
    
    

}

extension MyPageViewController: MajorTabViewController {
    func willTabSeleted() {

    }

    func didTabSeleted() {

    }
}

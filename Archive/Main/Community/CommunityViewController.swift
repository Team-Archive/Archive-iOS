//
//  CommunityViewController.swift
//  Archive
//
//  Created by hanwe on 2022/05/14.
//

import UIKit
import SnapKit
import ReactorKit
import RxCocoa
import RxSwift
import Then
import RxDataSources

class CommunityViewController: UIViewController, View, ActivityIndicatorable {
    
    // MARK: UI property
    
    private let mainBackgroundView = UIView().then {
        $0.backgroundColor = Gen.Colors.white.color
    }
    
    private let mainContentsView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private let topContentsContainerView = UIView().then {
//        $0.backgroundColor = Gen.Colors.white.color
        $0.backgroundColor = .brown // 임시
    }
    private let topContentsContainerViewHeight: CGFloat = 94
    
    private lazy var collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: UICollectionViewLayout()).then {
        $0.delaysContentTouches = false
        $0.contentInset = UIEdgeInsets(top: self.topContentsContainerViewHeight + 10, left: 0, bottom: 0, right: 0)
        $0.alwaysBounceVertical = true
        
        $0.backgroundColor = Gen.Colors.white.color
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 24
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 1.08)
        $0.collectionViewLayout = layout
    }
    
    
    // MARK: private property
    
    // MARK: property
    var disposeBag: DisposeBag = DisposeBag()
    
    // MARK: lifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.register(CommunityCollectionViewCell.self, forCellWithReuseIdentifier: CommunityCollectionViewCell.identifier)
        self.reactor?.action.onNext(.getPublicArchives(sortBy: .createdAt, emotion: nil))
    }
    
    init(reactor: CommunityReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
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
    
    func bind(reactor: CommunityReactor) {
        
        reactor.err
            .asDriver(onErrorJustReturn: .init(.commonError))
            .drive(onNext: { err in
                CommonAlertView.shared.show(message: err.getMessage(), btnText: "확인", hapticType: .error, confirmHandler: {
                    CommonAlertView.shared.hide(nil)
                })
            })
            .disposed(by: self.disposeBag)
        
        reactor.state
            .map { $0.isLoading }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] in
                if $0 {
                    self?.startIndicatorAnimating()
                } else {
                    self?.stopIndicatorAnimating()
                }
            })
            .disposed(by: self.disposeBag)
        
        reactor.state
            .map { $0.isShimmerLoading }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] in
                if $0 {
                    self?.startIndicatorAnimating()
                } else {
                    self?.stopIndicatorAnimating()
                }
            })
            .disposed(by: self.disposeBag)
        
        reactor.state
            .map { $0.archives }
            .distinctUntilChanged()
            .bind(to: self.collectionView.rx.items(cellIdentifier: CommunityCollectionViewCell.identifier, cellType: CommunityCollectionViewCell.self)) { index, element, cell in
                cell.infoData = element
            }
            .disposed(by: self.disposeBag)
        
    }
    
    deinit {
        print("\(self) deinit")
    }
    
    // MARK: private func
    
    // MARK: func

}

extension CommunityViewController: MajorTabViewController {
    func willTabSeleted() {
        
    }
    
    func didTabSeleted() {
        
    }
}

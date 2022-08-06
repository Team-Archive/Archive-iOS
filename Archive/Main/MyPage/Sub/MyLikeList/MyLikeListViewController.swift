//
//  MyLikeListViewController.swift
//  Archive
//
//  Created by hanwe on 2022/07/31.
//

import UIKit
import SnapKit
import ReactorKit
import RxCocoa
import RxSwift
import Then
import RxDataSources
import RxRelay

struct MyLikeHeaderSection {
    var items: [Int]
    var identity: Int {
        return 0
    }
}

extension MyLikeHeaderSection: AnimatableSectionModelType {
    init(original: MyLikeHeaderSection, items: [Int]) {
        self = original
        self.items = items
    }
}

struct MyLikeArchiveSection {
    var items: [MyLikeArchive]
    var identity: Int {
        return 0
    }
}

extension MyLikeArchiveSection: AnimatableSectionModelType {
    init(original: MyLikeArchiveSection, items: [MyLikeArchive]) {
        self = original
        self.items = items
    }
}

class MyLikeListViewController: UIViewController, View, ActivityIndicatorable, ActivityIndicatorableBasic {
    
    // MARK: UI property
    
    private let mainBackgroundView = UIView().then {
        $0.backgroundColor = Gen.Colors.white.color
    }
    
    private let mainContentsView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private lazy var collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: UICollectionViewLayout()).then {
        $0.delaysContentTouches = false
        $0.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        $0.alwaysBounceVertical = true
        
        $0.backgroundColor = Gen.Colors.white.color
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 24
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 1.08)
        layout.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: 60)
        $0.collectionViewLayout = layout
    }
    
    
    // MARK: private property
    
    typealias ArchiveSectionDataSource = RxCollectionViewSectionedAnimatedDataSource<MyLikeArchiveSection>
    private lazy var dataSource: ArchiveSectionDataSource = {
        let configuration = AnimationConfiguration(insertAnimation: .automatic, reloadAnimation: .automatic, deleteAnimation: .automatic)
        
        let ds = ArchiveSectionDataSource(animationConfiguration: configuration) { datasource, collectionView, indexPath, item in
            var cell = self.makeArhiveCell(item, from: collectionView, indexPath: indexPath)
            
            return cell
        }
        
        return ds
    }()
    private var sections = BehaviorRelay<[MyLikeArchiveSection]>(value: [])
    
    private var refresher: UIRefreshControl?
    
    // MARK: property
    var disposeBag: DisposeBag = DisposeBag()
    
    // MARK: lifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.register(MyLikeCollectionViewCell.self, forCellWithReuseIdentifier: MyLikeCollectionViewCell.identifier)
        collectionView.register(MyLikeListLikeCountHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: MyLikeListLikeCountHeaderView.identifier)
        setupDatasource()
        self.reactor?.action.onNext(.getMyLikeArchives)
    }
    
    init(reactor: MyPageReactor) {
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
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(reactor: MyPageReactor) {
        
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
                    self?.startBasicIndicatorAnimating()
                } else {
                    self?.stopBasicIndicatorAnimating()
                }
            })
            .disposed(by: self.disposeBag)
        
//        reactor.state
//            .map { $0.isShimmerLoading }
//            .distinctUntilChanged()
//            .asDriver(onErrorJustReturn: false)
//            .drive(onNext: { [weak self] in
//                if $0 {
//                    self?.startIndicatorAnimating()
//                } else {
//                    self?.stopIndicatorAnimating()
//                }
//            })
//            .disposed(by: self.disposeBag)
        
        reactor.state
            .map { $0.myLikeArchives }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: [])
            .drive(onNext: { [weak self] archives in
                self?.sections.accept([MyLikeArchiveSection(items: archives)])
            })
            .disposed(by: self.disposeBag)
        
//        self.collectionView.rx.itemSelected
//            .asDriver()
//            .drive(onNext: { [weak self] index in
//                reactor.action.onNext(.showDetail(index: index.item))
//            })
//            .disposed(by: self.disposeBag)
        
//        self.collectionView.rx.contentOffset
//            .asDriver()
//            .drive(onNext: { [weak self] offset in
//                if (offset.y > (self?.collectionView.contentSize.height ?? 1000000000000) - ((UIScreen.main.bounds.width * 1.08)*2)) &&
//                    offset.y > 1 {
//                    reactor.action.onNext(.getMorePublicArchives)
//                }
//            })
//            .disposed(by: self.disposeBag)
        
    }
    
    deinit {
        print("\(self) deinit")
    }
    
    // MARK: private func
    
    private func makeArhiveCell(_ archive: MyLikeArchive, from collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyLikeCollectionViewCell.identifier, for: indexPath) as? MyLikeCollectionViewCell else { return UICollectionViewCell() }
        cell.infoData = archive
        return cell
    }
    
    private func makeArhiveFilterCell(from collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CommunityFilterCollectionViewCell.identifier, for: indexPath) as? CommunityFilterCollectionViewCell else { return UICollectionViewCell() }
        return cell
    }
    
    private func setupDatasource() {
        self.collectionView.dataSource = nil
        dataSource.configureSupplementaryView = { (dataSource, collectionView, kind, indexPath) in
            if kind == UICollectionView.elementKindSectionHeader {
                if let section = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: MyLikeListLikeCountHeaderView.identifier, for: indexPath) as? MyLikeListLikeCountHeaderView {
                    
                    return section
                } else {
                    return UICollectionReusableView()
                }
            } else {
                return UICollectionReusableView()
            }
        }
        
        sections.bind(to: self.collectionView.rx.items(dataSource: dataSource))
            .disposed(by: self.disposeBag)
    }
    
    // MARK: func

}

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
import RxRelay

struct FilterSection {
    var items: [Int]
    var identity: Int {
        return 0
    }
}

extension FilterSection: AnimatableSectionModelType {
    init(original: FilterSection, items: [Int]) {
        self = original
        self.items = items
    }
}

struct ArchiveSection {
    var items: [PublicArchive]
    var identity: Int {
        return 0
    }
}

extension ArchiveSection: AnimatableSectionModelType {
    init(original: ArchiveSection, items: [PublicArchive]) {
        self = original
        self.items = items
    }
}

class CommunityViewController: UIViewController, View, ActivityIndicatorable {
    
    // MARK: UI property
    
    private let mainBackgroundView = UIView().then {
        $0.backgroundColor = Gen.Colors.white.color
    }
    
    private let mainContentsView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private let topContentsContainerView = UIView().then {
        $0.backgroundColor = .clear
    }
    private let topContentsContainerViewHeight: CGFloat = 94
    
    private lazy var bannerView = ArchiveBannerView().then {
        $0.backgroundColor = Gen.Colors.white.color
    }
    
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
        layout.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: 60)
        $0.collectionViewLayout = layout
    }
    
    
    // MARK: private property
    
    typealias ArchiveSectionDataSource = RxCollectionViewSectionedAnimatedDataSource<ArchiveSection>
    private lazy var dataSource: ArchiveSectionDataSource = {
        let configuration = AnimationConfiguration(insertAnimation: .automatic, reloadAnimation: .automatic, deleteAnimation: .automatic)
        
        let ds = ArchiveSectionDataSource(animationConfiguration: configuration) { datasource, collectionView, indexPath, item in
            var cell = self.makeArhiveCell(item, from: collectionView, indexPath: indexPath)
            
            return cell
        }
        
        return ds
    }()
    private var sections = BehaviorRelay<[ArchiveSection]>(value: [])
    
    private lazy var filterViewController = FilterViewController(timeSortBy: self.reactor?.currentState.archiveTimeSortBy ?? .sortByRegist,
                                                                 emotionSortBy: self.reactor?.currentState.archiveEmotionSortBy)
    
    // MARK: property
    var disposeBag: DisposeBag = DisposeBag()
    
    // MARK: lifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.register(CommunityCollectionViewCell.self, forCellWithReuseIdentifier: CommunityCollectionViewCell.identifier)
        collectionView.register(CommunityFilterHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CommunityFilterHeaderView.identifier)
        self.reactor?.action.onNext(.getPublicArchives(sortBy: .createdAt, emotion: nil))
        setupDatasource()
        self.bannerView.register(CommnunityBannerViewCell.self, forCellWithReuseIdentifier: CommnunityBannerViewCell.identifier)
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
        
        self.topContentsContainerView.addSubview(self.bannerView)
        self.bannerView.snp.makeConstraints {
            $0.edges.equalTo(self.topContentsContainerView)
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
            .asDriver(onErrorJustReturn: [])
            .drive(onNext: { [weak self] archives in
                self?.sections.accept([ArchiveSection(items: archives)])
            })
            .disposed(by: self.disposeBag)
        
        self.collectionView.rx.itemSelected
            .asDriver()
            .drive(onNext: { [weak self] index in
                reactor.action.onNext(.showDetail(index: index.item))
            })
            .disposed(by: self.disposeBag)
        
    }
    
    deinit {
        print("\(self) deinit")
    }
    
    // MARK: private func
    
    private func makeArhiveCell(_ archive: PublicArchive, from collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CommunityCollectionViewCell.identifier, for: indexPath) as? CommunityCollectionViewCell else { return UICollectionViewCell() }
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
                if let section = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CommunityFilterHeaderView.identifier, for: indexPath) as? CommunityFilterHeaderView {
                    section.delegate = self
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

extension CommunityViewController: CommunityFilterHeaderViewDelegate {
    func clickedFilterBtn() {
        self.filterViewController.modalPresentationStyle = .overFullScreen
        self.present(self.filterViewController, animated: false, completion: { [weak self] in
            self?.filterViewController.showEffect()
        })
        self.filterViewController.rx.selected
            .subscribe(onNext: { [weak self] sortBy, emotion, isAllSelected in
                print("test: \(sortBy) \(emotion) \(isAllSelected)")
            })
            .disposed(by: self.disposeBag)
    }
}

extension CommunityViewController: MajorTabViewController {
    func willTabSeleted() {
        
    }
    
    func didTabSeleted() {
        
    }
}

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

class CommunityViewController: UIViewController, View, ActivityIndicatorable, ActivityIndicatorableBasic {
    
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
        $0.onceMoveWidth = UIScreen.main.bounds.width
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: self.topContentsContainerViewHeight)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        $0.layout = layout
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
        layout.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: 60)
        $0.collectionViewLayout = layout
        $0.delegate = self
    }
    
    
    // MARK: private property
    
    typealias ArchiveSectionDataSource = RxCollectionViewSectionedAnimatedDataSource<ArchiveSection>
    private lazy var dataSource: ArchiveSectionDataSource = {
        let configuration = AnimationConfiguration(insertAnimation: .automatic, reloadAnimation: .automatic, deleteAnimation: .automatic)
        
        let ds = ArchiveSectionDataSource(animationConfiguration: configuration) { datasource, collectionView, indexPath, item in
            var cell = self.makeArchiveCell(item, from: collectionView, indexPath: indexPath)
            
            return cell
        }
        
        return ds
    }()
    private var sections = BehaviorRelay<[ArchiveSection]>(value: [])
    
    private lazy var filterViewController = FilterViewController(timeSortBy: self.reactor?.currentState.archiveTimeSortBy ?? .sortByRegist,
                                                                 emotionSortBy: self.reactor?.currentState.archiveEmotionSortBy)
    
    private var refresher: UIRefreshControl?
    private var isRefreshing: Bool = false
    
    // MARK: property
    var disposeBag: DisposeBag = DisposeBag()
    
    // MARK: lifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.register(CommunityCollectionViewCell.self, forCellWithReuseIdentifier: CommunityCollectionViewCell.identifier)
        collectionView.register(CommunityFilterHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CommunityFilterHeaderView.identifier)
        self.reactor?.action.onNext(.getFirstPublicArchives(sortBy: .sortByRegist, emotion: nil))
        setupDatasource()
        self.bannerView.register(CommunityBannerViewCell.self, forCellWithReuseIdentifier: CommunityBannerViewCell.identifier)
        self.reactor?.action.onNext(.getBannerInfo)
        NotificationCenter.default.addObserver(self, selector: #selector(self.likeQueryDoneNotificationReceive(notification:)), name: Notification.Name(NotificationDefine.LIKE_QUERY_DONE), object: nil)
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
        
        self.refresher = UIRefreshControl()
        if let refresher = refresher {
            refresher.tintColor = Gen.Colors.black.color
            refresher.addTarget(self, action: #selector(refresh), for: .valueChanged)
            self.collectionView.addSubview(refresher)
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
                    self?.startBasicIndicatorAnimating()
                } else {
                    self?.stopBasicIndicatorAnimating()
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
            .map { $0.archives.value }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: [])
            .drive(onNext: { [weak self] archives in
                self?.sections.accept([ArchiveSection(items: archives)])
            })
            .disposed(by: self.disposeBag)
        
        reactor.state
            .map { $0.archives }
            .asDriver(onErrorJustReturn: .init(wrappedValue: []))
            .drive(onNext: { [weak self] _ in
                if self?.isRefreshing ?? false {
                    self?.stopRefresher()
                    self?.isRefreshing = false
                }
            })
            .disposed(by: self.disposeBag)
        
        self.collectionView.rx.itemSelected
            .asDriver()
            .drive(onNext: { [weak self] index in
                reactor.action.onNext(.showDetail(index: index.item))
            })
            .disposed(by: self.disposeBag)
        
        reactor.state
            .map { $0.bannerInfo }
            .distinctUntilChanged()
            .bind(to: self.bannerView.rx.items(cellIdentifier: CommunityBannerViewCell.identifier,
                                               cellType: CommunityBannerViewCell.self)) { item, element, cell in
                cell.infoData = element
            }
            .disposed(by: self.disposeBag)
        
        self.bannerView.rx.didSelectedItem
            .subscribe(onNext: { [weak self] selectedIndex in
                reactor.action.onNext(.bannerClicked(index: selectedIndex))
            })
            .disposed(by: self.disposeBag)
        
        self.collectionView.rx.contentOffset
            .asDriver()
            .drive(onNext: { [weak self] offset in
                if offset.y > 0 {
                    let translation = self?.collectionView.panGestureRecognizer.translation(in: self?.collectionView.superview ?? UIScrollView())
                    if translation?.y ?? 0 > 0 {
                        if self?.bannerView.isHidden ?? false {
                            self?.bannerView.showWithAnimation()
                        }
                    } else {
                        self?.bannerView.hideWithAnimation()
                    }
                } else {
                    self?.bannerView.showWithAnimation()
                }
            })
            .disposed(by: self.disposeBag)
        
        self.collectionView.rx.willDisplayCell
            .subscribe(onNext: { info in
                if reactor.currentState.archives.value.count - 3 < info.at.item {
                    reactor.action.onNext(.getMorePublicArchives)
                }
            })
            .disposed(by: self.disposeBag)
        
        self.filterViewController.rx.selected
            .subscribe(onNext: { [weak self] sortBy, emotion, isAllSelected in
                if isAllSelected {
                    self?.reactor?.action.onNext(.getFirstPublicArchives(sortBy: sortBy, emotion: nil))
                } else {
                    self?.reactor?.action.onNext(.getFirstPublicArchives(sortBy: sortBy, emotion: emotion))
                }
            })
            .disposed(by: self.disposeBag)
        
    }
    
    deinit {
        print("\(self) deinit")
    }
    
    // MARK: private func
    
    private func makeArchiveCell(_ archive: PublicArchive, from collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CommunityCollectionViewCell.identifier, for: indexPath) as? CommunityCollectionViewCell else { return UICollectionViewCell() }
        cell.infoData = archive
        cell.index = indexPath.item
        cell.isLike = LikeManager.shared.likeList.contains("\(archive.archiveId)")
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
    
    @objc private func refresh() {
        print("refresh")
        self.isRefreshing = true
        self.reactor?.action.onNext(.refreshPublicArchives)
    }
    
    private func stopRefresher() {
        print("stopRefresher")
        self.refresher?.endRefreshing()
    }
    
    @objc private func likeQueryDoneNotificationReceive(notification: Notification) {
        guard let changedArchiveIdSet = notification.object as? Set<String> else { return }
        DispatchQueue.main.async { [weak self] in
            _ = self?.collectionView.visibleCells.map { [weak self] in
                if let cell = ($0 as? CommunityCollectionViewCell) {
                    if changedArchiveIdSet.contains("\(cell.infoData?.archiveId ?? 0)") {
                        if cell.index != -1 {
                            self?.collectionView.reloadItems(at: [IndexPath(item: cell.index, section: 0)])
                        }
                    }
                }
            }
        }
    }
    
    // MARK: func

}

extension CommunityViewController: CommunityFilterHeaderViewDelegate {
    func clickedFilterBtn() {
        self.filterViewController.modalPresentationStyle = .overFullScreen
        self.present(self.filterViewController, animated: false, completion: { [weak self] in
            self?.filterViewController.showEffect()
        })
    }
}

extension CommunityViewController: MajorTabViewController {
    
    func willTabSeleted() {
        self.collectionView.reloadData()
    }
    
    func didTabSeleted() {
        self.bannerView.isAutoScrolling = true
    }
    
    func willUnselected() {
        self.bannerView.isAutoScrolling = false
    }
    
}

extension CommunityViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let defaultSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 1.08)
        guard let reactor = self.reactor else { return defaultSize }
        let cellTitleWidth = CommunityCollectionViewCell.titleWidth
        let item = reactor.currentState.archives.value[indexPath.item]
        let currentTitleWidth = item.archiveName.width(withConstrainedHeight: 0, font: .fonts(.header3))
        let archiveNameArr = (self.reactor?.currentState.archives.value[indexPath.item].archiveName ?? "").split(separator: "\n")
        if currentTitleWidth >= cellTitleWidth || archiveNameArr.count > 1 {
            return .init(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 1.08 + 30)
        } else {
            return defaultSize
        }
    }
}

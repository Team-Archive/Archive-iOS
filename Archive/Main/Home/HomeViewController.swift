//
//  HomeViewController.swift
//  Archive
//
//  Created by TTOzzi on 2021/10/30.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa
import RxDataSources

final class HomeViewController: UIViewController, StoryboardView, ActivityIndicatorable, FakeSplashViewProtocol {
    
    // MARK: IBOutlet
    @IBOutlet weak var mainContainerView: UIView!
    @IBOutlet weak var contentsCountTitleLabel: UILabel!
    @IBOutlet weak var contentsCountLabel: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var emptyTicketImageView: UIImageView!
    @IBOutlet private weak var ticketCollectionView: UICollectionView! {
        didSet {
            let collectionViewLayout = TicketCollectionViewLayout(visibleItemsCount: 3,
                                                                  minimumScale: 0.8,
                                                                  horizontalInset: 32,
                                                                  spacing: 24)
            ticketCollectionView.collectionViewLayout = collectionViewLayout
            ticketCollectionView.delaysContentTouches = false
        }
    }
    
    @IBOutlet weak var filterBtn: ImageButton!
    
    // MARK: private UI property
    
    private lazy var filterViewController = FilterViewController(timeSortBy: .sortByRegist, emotionSortBy: nil)
    
    
    // MARK: private property
    
    private let shimmerView: HomeShimmerView? = HomeShimmerView.instance()
    private var didScrollecDirection: Direction = .left
    
    // MARK: internal property
    
    var disposeBag = DisposeBag()
    weak var targetView: UIView?
    var attachedView: UIView? = FakeSplashView()
    
    // MARK: lifeCycle
    
    init?(coder: NSCoder, reactor: HomeReactor) {
        super.init(coder: coder)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        self.reactor?.action.onNext(.getMyArchives(sortType: .sortByRegist, emotion: nil))
        NotificationCenter.default.addObserver(self, selector: #selector(self.archiveIsAddedNotificationReceive(notification:)), name: Notification.Name(NotificationDefine.ARCHIVE_IS_ADDED), object: nil)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let status = ArchiveStatus.shared
        if !status.isShownFakeSplash {
            self.targetView = self.view
            showSplashView()
            hideSplashView()
            status.runFakeSplash()
        }
    }
    
    func bind(reactor: HomeReactor) {
        
        reactor.state.map { $0.archives }
        .distinctUntilChanged()
        .bind(to: self.ticketCollectionView.rx.items(cellIdentifier: TicketCollectionViewCell.identifier, cellType: TicketCollectionViewCell.self)) { index, element, cell in
            cell.infoData = element
        }
        .disposed(by: self.disposeBag)
        
        reactor.state
            .map { $0.archives }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] in
                ArchiveStatus.shared.currentArchives.onNext($0)
            })
            .disposed(by: self.disposeBag)
        
        reactor.state
            .map { $0.archives }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: [])
            .drive(onNext: { [weak self] in
                if $0.count == 0 {
                    self?.emptyTicketImageView.isHidden = false
                    self?.ticketCollectionView.isHidden = true
                } else {
                    self?.emptyTicketImageView.isHidden = true
                    self?.ticketCollectionView.isHidden = false
                    self?.moveCollectionViewFirstIndex()
                }
            })
            .disposed(by: self.disposeBag)
        
        reactor.state.map { $0.arvhivesCount }
        .distinctUntilChanged()
        .map { String("\($0)") }
        .bind(to: self.contentsCountLabel.rx.text)
        .disposed(by: self.disposeBag)
        
        reactor.state.map { $0.arvhivesCount }
        .distinctUntilChanged()
        .map { String("\($0)") }
        .bind(to: self.contentsCountLabel.rx.text)
        .disposed(by: self.disposeBag)
        
        reactor.state.map { $0.arvhivesCount }
        .distinctUntilChanged()
        .bind(to: self.pageControl.rx.numberOfPages)
        .disposed(by: self.disposeBag)
        
        self.ticketCollectionView.rx.willBeginDragging
            .subscribe(onNext: { [weak self] in
                guard let translation = self?.ticketCollectionView.panGestureRecognizer.translation(in: self?.ticketCollectionView.superview) else { return }
                if translation.x > 0 {
                    self?.didScrollecDirection = .left
                } else {
                    self?.didScrollecDirection = .right
                }
            })
            .disposed(by: self.disposeBag)
        
        self.ticketCollectionView.rx.contentOffset
            .map { $0.x }
            .subscribe(onNext: { [weak self] xOffset in
                let screenWidth: CGFloat = UIScreen.main.bounds.width
                let currentIndex: Int = Int(xOffset/screenWidth)
                self?.pageControl?.currentPage = currentIndex
            })
            .disposed(by: self.disposeBag)
        
        self.ticketCollectionView.rx.itemSelected
            .asDriver()
            .drive(onNext: { info in
                reactor.action.onNext(.showDetail(info.item))
            })
            .disposed(by: self.disposeBag)
        
        reactor.state.map { $0.isLoading }
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
        
//        reactor.state.map { $0.isShimmering } // 추후 업데이트 예정
//        .distinctUntilChanged()
//        .asDriver(onErrorJustReturn: false)
//        .drive(onNext: { [weak self] in
//            if $0 {
//                self?.shimmerView?.isHidden = false
//                self?.shimmerView?.startShimmering()
//            } else {
//                self?.shimmerView?.stopShimmering()
//                self?.shimmerView?.isHidden = true
//            }
//        })
//        .disposed(by: self.disposeBag)
        
        reactor.state.map { $0.isShimmering } // 추후 업데이트 예정
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
        
        self.filterBtn.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.filterViewController.modalPresentationStyle = .overFullScreen
                self?.present(self?.filterViewController ?? UIViewController(), animated: false, completion: { [weak self] in
                    self?.filterViewController.showEffect()
                })
            })
            .disposed(by: self.disposeBag)
        
        self.filterViewController.rx.selected
            .subscribe(onNext: { [weak self] sortBy, emotion, isAllSelected in
                if isAllSelected {
                    self?.reactor?.action.onNext(.getMyArchives(sortType: sortBy, emotion: nil))
                } else {
                    self?.reactor?.action.onNext(.getMyArchives(sortType: sortBy, emotion: emotion))
                }
            })
            .disposed(by: self.disposeBag)
            
        
    }
    
    // MARK: private function
    
    private func initUI() {
        if let shimmerView = self.shimmerView {
            self.mainContainerView.addSubview(shimmerView)
            shimmerView.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
            shimmerView.isHidden = true
        }
        self.contentsCountTitleLabel.font = .fonts(.subTitle)
        self.contentsCountTitleLabel.textColor = Gen.Colors.black.color
        self.contentsCountTitleLabel.text = "기록한 전시"
        self.contentsCountLabel.font = .fonts(.header3)
        self.contentsCountLabel.textColor = Gen.Colors.black.color
        self.pageControl.pageIndicatorTintColor = Gen.Colors.gray03.color
        self.pageControl.currentPageIndicatorTintColor = Gen.Colors.gray01.color
        self.pageControl.isEnabled = false
        
        self.filterBtn.buttonTitle = "필터"
        self.filterBtn.buttonImage = Gen.Images.filter.image
    }
    
    @objc private func archiveIsAddedNotificationReceive(notification: Notification) {
        self.reactor?.action.onNext(.refreshMyArchives)
    }
    
    private func moveCollectionViewFirstIndex() {
        DispatchQueue.main.async { [weak self] in
            if self?.reactor?.currentState.archives.count ?? 0 > 1 {
                self?.ticketCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0),
                                                        at: .left,
                                                        animated: false)
            }
        }
    }
    
    // MARK: internal function
    
    func willDeletedIndex(_ index: Int) {
        DispatchQueue.main.async { [weak self] in
            guard let reactor = self?.reactor else {
                return
            }
            if index+1 >= reactor.currentState.archives.count {
                self?.ticketCollectionView.scrollToItem(at: IndexPath(item: index-1, section: 0), at: .top, animated: false)
            }
        }
    }
    
    // MARK: action
    
}

extension HomeViewController: MajorTabViewController {
    
    func willTabSeleted() {
        
    }
    
    func didTabSeleted() {
        
    }
    
    func willUnselected() {
        
    }
    
}

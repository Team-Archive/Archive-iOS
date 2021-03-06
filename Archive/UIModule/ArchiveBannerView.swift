//
//  ArchiveBannerView.swift
//  Archive
//
//  Created by hanwe on 2022/07/16.
//

import UIKit
import SnapKit
import Then
import SwiftyTimer
import RxCocoa
import RxSwift


class ArchiveBannerViewCell: UICollectionViewCell {
}

@objc protocol ArchiveBannerViewDelegate: AnyObject {
    @objc optional func pagerView(_ pagerView: ArchiveBannerView, didSelectItemAt itemIndex: Int)
}

protocol ArchiveBannerViewDatasource: AnyObject {
    func ArchiveBannerView(_ ArchiveBannerView: ArchiveBannerView) -> Int
    func ArchiveBannerView(_ ArchiveBannerView: ArchiveBannerView, cellForItemAt itemAt: UInt) -> ArchiveBannerViewCell
}

class ArchiveBannerView: UIView {
    
    // MARK: private UI property
    
    lazy var collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: UICollectionViewFlowLayout()).then {
        $0.backgroundColor = self.backgroundColor
        $0.delegate = self
        $0.dataSource = self
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.isPagingEnabled = true // TODO: 나중에 estimate로 양 옆이 보이도록 업그레이드
    }
    
    fileprivate lazy var pageControl = UIPageControl().then {
        $0.numberOfPages = 0
        $0.isUserInteractionEnabled = false
    }
    
    // MARK: internal UI property
    
    // MARK: property
    
    weak var delegate: ArchiveBannerViewDelegate?
    weak var datasource: ArchiveBannerViewDatasource?
    
    override var backgroundColor: UIColor? {
        didSet {
            self.collectionView.backgroundColor = self.backgroundColor
        }
    }
    
    var layout: UICollectionViewLayout = UICollectionViewLayout() {
        didSet {
            self.collectionView.collectionViewLayout = layout
        }
    }
    
    var isAutoScrolling: Bool = false {
        didSet {
            if self.isAutoScrolling {
                self.timer?.invalidate()
                self.timer = nil
                self.timer = makeTimer()
                self.timer?.start(runLoop: .current, modes: .default)
            } else {
                self.timer?.invalidate()
                self.timer = nil
            }
        }
    }
    
    var autoScrollingTimeInterval: TimeInterval = 4.5
    var isHiddenPageControl: Bool = false {
        didSet {
            if self.isHiddenPageControl {
                self.pageControl.isHidden = true
            } else {
                self.pageControl.isHidden = false
            }
        }
    }
    
    var onceMoveWidth: CGFloat = UIScreen.main.bounds.width // TODO: 나중에 의미 있게 만들자.
    var isFirstLoad: Bool = false // 이 뷰가 데이터가 셋 되고 처음 로드되었는지를 나타낸다. 진짜 인덱스를 1번으로 바꾸기위해 필요함.
    
    override var isHidden: Bool {
        didSet {
            if self.isHidden {
                self.timer?.invalidate()
                self.timer = nil
            } else {
                if self.isAutoScrolling {
                    self.isAutoScrolling = true
                }
            }
        }
    }
    // MARK: private Property
    
    fileprivate var numberOfItems: UInt = 0
    private var realCurrentPage: Int = 1
    private(set) var currentPage: Int = 0 {
        didSet {
            self.pageControl.currentPage = self.currentPage
        }
    }
    private var timer: Timer?
    private var isShowHideAnimationPlaying: Bool = false
    
    // MARK: lifeCycle
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        setup()
    }
    
    // MARK: private func
    
    private func setup() {
        self.collectionView.contentOffset = CGPoint(x: self.onceMoveWidth, y: 0)
        
        self.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints {
            $0.edges.equalTo(self)
        }
        
        self.addSubview(self.pageControl)
        self.pageControl.snp.makeConstraints {
            $0.bottom.equalTo(self.snp.bottom)
            $0.centerX.equalTo(self.snp.centerX)
            $0.width.equalTo(160)
        }
    }
    
    private func makeTimer() -> Timer {
        return Timer.scheduledTimer(withTimeInterval: self.autoScrollingTimeInterval, repeats: true, block: { [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                self?.moveNextPage()
            }
        })
    }
    
    // MARK: func
    
    func register(_ cellClass: UINib, _ forCellWithReuseIdentifier: String) {
        self.collectionView.register(cellClass, forCellWithReuseIdentifier: forCellWithReuseIdentifier)
    }
    
    func register(_ cellClass: AnyClass?, forCellWithReuseIdentifier: String) {
        self.collectionView.register(cellClass, forCellWithReuseIdentifier: forCellWithReuseIdentifier)
    }
    
    func dequeueReusableCell(withReuseIdentifier: String, index at: UInt) -> ArchiveBannerViewCell {
        return self.collectionView.dequeueReusableCell(withReuseIdentifier: withReuseIdentifier, for: IndexPath(item: Int(at), section: 0)) as? ArchiveBannerViewCell ?? ArchiveBannerViewCell()
    }
    
    func movePage(page: UInt, animated: Bool = true) {
        self.collectionView.scrollToItem(at: IndexPath(item: Int(page+1), section: 0), at: .left, animated: animated)
    }
    
    func moveNextPage(animated: Bool = true) {
        if self.pageControl.numberOfPages > 0 {
            self.collectionView.scrollToItem(at: IndexPath(item: Int(self.realCurrentPage + 1), section: 0), at: .left, animated: animated)
        }
    }
    
    func hideWithAnimation() {
        if !self.isShowHideAnimationPlaying && !self.isHidden {
            self.isShowHideAnimationPlaying = true
            self.fadeOut(duration: 0.1) { [weak self] in
                self?.isHidden = true
                self?.isShowHideAnimationPlaying = false
            }
        }
    }
    
    func showWithAnimation() {
        if !self.isShowHideAnimationPlaying && self.isHidden {
            self.isShowHideAnimationPlaying = true
            self.alpha = 0
            self.isHidden = false
            self.fadeIn(duration: 0.1, completeHandler: { [weak self] in
                self?.isShowHideAnimationPlaying = false
            })
        }
        

    }
    
}

extension ArchiveBannerView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let page = Int(collectionView.contentOffset.x/self.onceMoveWidth)
        self.realCurrentPage = page
        self.currentPage = page - 1
        if realCurrentPage == 0 {
            self.collectionView.contentOffset = CGPoint(x: collectionView.frame.size.width * CGFloat(numberOfItems), y: collectionView.contentOffset.y)
            self.currentPage = Int(self.numberOfItems) - 1
            self.realCurrentPage = Int(self.numberOfItems)
        } else if realCurrentPage == numberOfItems + 1 {
            self.collectionView.contentOffset = CGPoint(x: self.onceMoveWidth, y: collectionView.contentOffset.y)
            self.currentPage = 0
            self.realCurrentPage = 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.delegate?.pagerView?(self, didSelectItemAt: self.currentPage)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if self.isAutoScrolling {
            self.timer?.invalidate()
            self.timer = nil
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if self.isAutoScrolling {
            self.timer?.invalidate()
            self.timer = nil
            self.timer = makeTimer()
        }
        
    }
    
}


extension ArchiveBannerView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let ds = self.datasource else { return 0 }
        self.numberOfItems = UInt(ds.ArchiveBannerView(self))
        self.pageControl.numberOfPages = Int(numberOfItems)
        return Int(self.numberOfItems + 2)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let ds = self.datasource else { return UICollectionViewCell() }
        var cell = UICollectionViewCell()
        if indexPath.item == 0 {
            cell = ds.ArchiveBannerView(self, cellForItemAt: UInt(self.numberOfItems - 1))
        } else if indexPath.item == self.numberOfItems + 1 {
            cell = ds.ArchiveBannerView(self, cellForItemAt: UInt(0))
        } else {
            cell = ds.ArchiveBannerView(self, cellForItemAt: UInt(indexPath.item - 1))
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == 0 && self.isFirstLoad {
            self.isFirstLoad = false
            self.movePage(page: 0, animated: false)
        }
    }
    
}

class ArchiveBannerViewDelegateProxy: DelegateProxy<ArchiveBannerView, ArchiveBannerViewDelegate>, DelegateProxyType, ArchiveBannerViewDelegate {

    static func registerKnownImplementations() {
        self.register { (viewController) -> ArchiveBannerViewDelegateProxy in
            ArchiveBannerViewDelegateProxy(parentObject: viewController, delegateProxy: self)
        }
    }

    static func currentDelegate(for object: ArchiveBannerView) -> ArchiveBannerViewDelegate? {
        return object.delegate
    }

    static func setCurrentDelegate(_ delegate: ArchiveBannerViewDelegate?, to object: ArchiveBannerView) {
        object.delegate = delegate
    }

}

extension Reactive where Base == ArchiveBannerView {

    var delegate: DelegateProxy<ArchiveBannerView, ArchiveBannerViewDelegate> {
        return ArchiveBannerViewDelegateProxy.proxy(for: self.base)
    }

    var didSelectedItem: Observable<Int> {
        return delegate.methodInvoked(#selector(ArchiveBannerViewDelegate.pagerView(_:didSelectItemAt:)))
            .map { param in
                return param[1] as? Int ?? 0
            }
    }
    
    typealias ConfigureCell<S: Sequence, Cell> = (Int, S.Iterator.Element, Cell) -> Void
    
    func items<S: Sequence, Cell: ArchiveBannerViewCell, O: ObservableType>(
        cellIdentifier: String,
        cellType: Cell.Type = Cell.self
    ) -> (_ source: O) -> (_ configureCell: @escaping ConfigureCell<S, Cell>) -> Disposable
    where O.Element == S {
        base.collectionView.dataSource = nil
        return { source in
            let source = source.observe(on: ConcurrentDispatchQueueScheduler(queue: .global()))
                .map { sequence -> [S.Element] in
                    let items: [S.Element] = {
                        var items = Array(sequence)
                        if items.count > 0 {
                            let lastItem = items.last!
                            let firstItme = items.first!
                            items.insert(lastItem, at: 0)
                            items.append(firstItme)
                        }
                        return items
                    }()
                    if items.count == 0 {
                        base.numberOfItems = 0
                    } else if items.count == 1 {
                        base.numberOfItems = 1
                    } else {
                        base.numberOfItems = UInt(items.count - 2)
                    }
                    DispatchQueue.main.async {
                        base.pageControl.numberOfPages = items.count - 2
                    }
                    base.isFirstLoad = true
                    return items
                }
            return self.base.collectionView.rx.items(
                cellIdentifier: cellIdentifier,
                cellType: cellType
            )(source)
        }
    }
    
}

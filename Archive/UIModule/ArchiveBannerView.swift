//
//  ArchiveBannerView.swift
//  Archive
//
//  Created by hanwe on 2022/07/16.
//

import UIKit
import SnapKit
import Then
import RxCocoa
import RxSwift


open class ArchiveBannerViewCell: UICollectionViewCell {
  
}

@objc public protocol ArchiveBannerViewDelegate: AnyObject {
  @objc optional func pagerView(_ pagerView: ArchiveBannerView, didSelectItemAt itemIndex: Int)
}

public protocol ArchiveBannerViewDatasource: AnyObject {
  func ArchiveBannerView(_ ArchiveBannerView: ArchiveBannerView) -> Int
  func ArchiveBannerView(_ ArchiveBannerView: ArchiveBannerView, cellForItemAt itemAt: UInt) -> ArchiveBannerViewCell
}

public class ArchiveBannerView: UIView {
  
  // MARK: private UI property
  
  public lazy var collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: UICollectionViewFlowLayout()).then {
    $0.backgroundColor = self.backgroundColor
    $0.delegate = self
    $0.dataSource = self
    $0.showsVerticalScrollIndicator = false
    $0.showsHorizontalScrollIndicator = false
    $0.isPagingEnabled = false
    $0.contentInsetAdjustmentBehavior = .never
    $0.decelerationRate = .fast
    $0.translatesAutoresizingMaskIntoConstraints = false

    let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    layout.minimumLineSpacing = self.minimumLineSpacing
    layout.minimumInteritemSpacing = 0
    layout.scrollDirection = .horizontal
    layout.itemSize = self.itemSize
    layout.sectionInset = .zero
    $0.collectionViewLayout = layout
  }

  
  private var layout: UICollectionViewLayout = UICollectionViewLayout() {
    didSet {
      self.collectionView.collectionViewLayout = layout
    }
  }
  
  fileprivate lazy var pageControl = UIPageControl().then {
    $0.numberOfPages = 0
    $0.isUserInteractionEnabled = false
  }
  
  // MARK: internal UI property
  
  // MARK: property
  
  public weak var delegate: ArchiveBannerViewDelegate?
  public weak var datasource: ArchiveBannerViewDatasource?
  
  public override var backgroundColor: UIColor? {
    didSet {
      self.collectionView.backgroundColor = self.backgroundColor
    }
  }
  
  public var isAutoScrolling: Bool = false {
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
  
  public var autoScrollingTimeInterval: TimeInterval = 4.5
  public var isHiddenPageControl: Bool = false {
    didSet {
      if self.isHiddenPageControl {
        self.pageControl.isHidden = true
      } else {
        self.pageControl.isHidden = false
      }
    }
  }
  
  public let onceMoveWidth: CGFloat
  public var isFirstLoad: Bool = false // 이 뷰가 데이터가 셋 되고 처음 로드되었는지를 나타낸다. 진짜 인덱스를 1번으로 바꾸기위해 필요함.
  
  public override var isHidden: Bool {
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
  private var realCurrentPage: Int = 2 {
    didSet {
      if self.realCurrentPage > self.numberOfItems + 1 { // 우측 끝으로 갔을때 자연스러움을 위해 스크롤 잠시 정지시킴.
        self.collectionView.isScrollEnabled = false
      }
    }
  }
  private(set) var currentPage: Int = 0 {
    didSet {
      self.pageControl.currentPage = self.currentPage
    }
  }
  private var timer: Timer?
  private var isShowHideAnimationPlaying: Bool = false
  private let itemSize: CGSize
  private lazy var centerOffset = (self.frame.width - self.itemSize.width)/2
  private var minimumLineSpacing: CGFloat
  
  // MARK: lifeCycle
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public init(itemSize: CGSize, minimumLineSpacing: CGFloat = 0) {
    self.itemSize = itemSize
    self.minimumLineSpacing = minimumLineSpacing
    self.onceMoveWidth = (itemSize.width + self.minimumLineSpacing)
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
  
  private func moveRatationIndex() {
    let defaultOffset: CGFloat = (onceMoveWidth * 2) - centerOffset
    if collectionView.contentOffset.x - defaultOffset < 0 {
      self.realCurrentPage = Int(self.numberOfItems + 2)
      self.currentPage = Int(self.numberOfItems)
      self.moveToLastPage(animated: false)
      self.collectionView.isScrollEnabled = true
    } else if realCurrentPage >= numberOfItems + 2 {
      self.realCurrentPage = 2
      self.currentPage = 0
      self.moveToFirstPage(animated: false)
      self.collectionView.isScrollEnabled = true
    }
  }
  
  // MARK: func
  
  public func register(_ cellClass: UINib, _ forCellWithReuseIdentifier: String) {
    self.collectionView.register(cellClass, forCellWithReuseIdentifier: forCellWithReuseIdentifier)
  }
  
  public func register(_ cellClass: AnyClass?, forCellWithReuseIdentifier: String) {
    self.collectionView.register(cellClass, forCellWithReuseIdentifier: forCellWithReuseIdentifier)
  }
  
  public func dequeueReusableCell(withReuseIdentifier: String, index at: UInt) -> ArchiveBannerViewCell {
    return self.collectionView.dequeueReusableCell(withReuseIdentifier: withReuseIdentifier, for: IndexPath(item: Int(at), section: 0)) as? ArchiveBannerViewCell ?? ArchiveBannerViewCell()
  }
  
  public func moveToFirstPage(animated: Bool = true) {
    self.collectionView.setContentOffset( CGPoint(x: (self.onceMoveWidth * 2) - self.centerOffset, y: 0), animated: animated)
  }
  
  public func moveToLastPage(animated: Bool = true) {
    self.collectionView.setContentOffset( CGPoint(x: (self.onceMoveWidth * CGFloat(2 + self.numberOfItems - 1)) - self.centerOffset, y: 0), animated: animated)
  }
  
  public func movePage(page: Int, animated: Bool = true) {
    self.collectionView.setContentOffset( CGPoint(x: (self.onceMoveWidth * CGFloat(page + 2)) - self.centerOffset, y: 0), animated: animated)
    self.realCurrentPage = page + 2
    self.currentPage = page
  }
  
  public func moveNextPage(animated: Bool = true) {
    if self.pageControl.numberOfPages > 0 {
      self.collectionView.setContentOffset( CGPoint(x: (self.onceMoveWidth * CGFloat(realCurrentPage + 1)) - self.centerOffset, y: 0), animated: animated)
      self.realCurrentPage += 1
      self.currentPage += 1
    }
  }
  
  public func hideWithAnimation() {
    if !self.isShowHideAnimationPlaying && !self.isHidden {
      self.isShowHideAnimationPlaying = true
      self.fadeOut(duration: 0.1) { [weak self] in
        self?.isHidden = true
        self?.isShowHideAnimationPlaying = false
      }
    }
  }
  
  public func showWithAnimation() {
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
  public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
    moveRatationIndex()
  }
  
  public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    moveRatationIndex()
  }
  
  public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
  }
  
  
  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if self.numberOfItems != 0 {
      let defaultOffset: CGFloat = (onceMoveWidth * 2) - centerOffset
      let page = Int((collectionView.contentOffset.x - defaultOffset + (onceMoveWidth/2))/(onceMoveWidth))
      self.realCurrentPage = page + 2
      self.currentPage = page
    }
  }
  
  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    self.delegate?.pagerView?(self, didSelectItemAt: self.currentPage)
  }
  
  public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    if self.isAutoScrolling {
      self.timer?.invalidate()
      self.timer = nil
    }
  }
  
  public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    if self.isAutoScrolling {
      self.timer?.invalidate()
      self.timer = nil
      self.timer = makeTimer()
    }
  }
  
  public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    let translation = scrollView.panGestureRecognizer.translation(in: scrollView.superview)
    if translation.x > 0 {
      if self.realCurrentPage == 2 {
        self.collectionView.isScrollEnabled = false // 좌측 끝으로 갔을때 자연스러움을 위해 스크롤 잠시 정지시킴.
      }
      targetContentOffset.pointee = .init(x: (CGFloat(realCurrentPage - 1) * onceMoveWidth) - centerOffset, y: 0)
    } else {
      targetContentOffset.pointee = .init(x: (CGFloat(realCurrentPage + 1) * onceMoveWidth) - centerOffset, y: 0)
    }
  }
  
}


extension ArchiveBannerView: UICollectionViewDataSource {
  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    guard let ds = self.datasource else { return 0 }
    self.numberOfItems = UInt(ds.ArchiveBannerView(self))
    self.pageControl.numberOfPages = Int(numberOfItems)
    return Int(self.numberOfItems + 4)
  }
  
  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let ds = self.datasource else { return UICollectionViewCell() }
    var cell = UICollectionViewCell()
    if indexPath.item == 0 {
      cell = ds.ArchiveBannerView(self, cellForItemAt: UInt(self.numberOfItems - 2))
    } else if indexPath.item == self.numberOfItems + 1 {
      cell = ds.ArchiveBannerView(self, cellForItemAt: UInt(0))
    } else {
      cell = ds.ArchiveBannerView(self, cellForItemAt: UInt(indexPath.item - 2))
    }
    return cell
  }
  
  public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    if self.isFirstLoad {
      self.isFirstLoad = false
      self.moveToFirstPage(animated: false)
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
  
  public var didSelectedItem: Observable<Int> {
    return delegate.methodInvoked(#selector(ArchiveBannerViewDelegate.pagerView(_:didSelectItemAt:)))
      .map { param in
        return param[1] as? Int ?? 0
      }
  }
  
  public typealias ConfigureCell<S: Sequence, Cell> = (Int, S.Iterator.Element, Cell) -> Void
  
  public func items<S: Sequence, Cell: ArchiveBannerViewCell, O: ObservableType>(
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
              let lastBeforeItem: S.Element = {
                if items.count > 1 {
                  return items[items.count - 2]
                } else {
                  return items.last!
                }
              }()
              let firstItme = items.first!
              let firstAfterItem: S.Element = {
                if items.count > 1 {
                  return items[1]
                } else {
                  return items.first!
                }
              }()
              items.insert(lastItem, at: 0)
              items.insert(lastBeforeItem, at: 0)
              items.append(firstItme)
              items.append(firstAfterItem)
            }
            return items
          }()
          if items.count == 0 {
            base.numberOfItems = 0
          } else {
            base.numberOfItems = UInt(items.count - 4)
          }
          DispatchQueue.main.async {
            base.pageControl.numberOfPages = items.count - 4
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

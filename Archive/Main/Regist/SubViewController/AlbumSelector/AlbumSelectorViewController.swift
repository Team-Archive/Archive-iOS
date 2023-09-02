//
//  AlbumSelectorViewController.swift
//  Archive
//
//  Created by hanwe on 2023/09/02.
//

import UIKit
import Then
import SnapKit
import RxSwift
import RxCocoa
import Photos
import RxDataSources

struct AlbumSection {
  var items: [AlbumModel]
  var identity: Int {
    return 0
  }
}

extension AlbumSection: AnimatableSectionModelType {
  init(original: AlbumSection, items: [AlbumModel]) {
    self = original
    self.items = items
  }
}

final class AlbumSelectorViewController: UIViewController {
  
  // MARK: UIProperty
  
  private let baseView = UIView().then {
    $0.backgroundColor = Gen.Colors.white.color
  }
  
  private lazy var collectionView = UICollectionView().then {
    $0.alwaysBounceVertical = true
    
    $0.backgroundColor = Gen.Colors.white.color
    let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    layout.minimumLineSpacing = 0
    layout.minimumInteritemSpacing = 12
    layout.scrollDirection = .vertical
    $0.collectionViewLayout = layout
    
    $0.register(AlbumSelectorCollectionViewCell.self, forCellWithReuseIdentifier: AlbumSelectorCollectionViewCell.identifier)
  }
  
  // MARK: private property
  
  private let list: [AlbumModel]
  private let disposeBag = DisposeBag()
  
  typealias AlbumSectionDataSource = RxCollectionViewSectionedAnimatedDataSource<AlbumSection>
  private lazy var dataSource: AlbumSectionDataSource = {
      let configuration = AnimationConfiguration(insertAnimation: .automatic, reloadAnimation: .automatic, deleteAnimation: .automatic)
      
      let ds = AlbumSectionDataSource(animationConfiguration: configuration) { datasource, collectionView, indexPath, item in
        return self.makeCell(item, from: collectionView, indexPath: indexPath)
      }
      
      return ds
  }()
  private var sections = BehaviorRelay<[AlbumSection]>(value: [])
  
  // MARK: internal property
  
  // MARK: lifeCycle
  
  init(list: [AlbumModel]) {
    self.list = list
    super.init(nibName: nil, bundle: nil)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupDatasource()
    bind()
    self.sections.accept([.init(items: self.list)])
  }
  
  // MARK: private function
  
  private func setup() {
    
    self.view.addSubview(self.baseView)
    let safeGuide = self.view.safeAreaLayoutGuide
    self.baseView.snp.makeConstraints {
      $0.edges.equalTo(safeGuide)
    }
    
    self.baseView.addSubview(self.collectionView)
    self.collectionView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }
  
  private func bind() {
    
//        self?.sections.accept([ArchiveSection(items: archives)])
  }
  
  private func setupDatasource() {
//    self.collectionView.dataSource = nil
    sections.bind(to: self.collectionView.rx.items(dataSource: dataSource))
      .disposed(by: self.disposeBag)
  }
  
  private func makeCell(_ model: AlbumModel, from collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AlbumSelectorCollectionViewCell.identifier, for: indexPath) as? AlbumSelectorCollectionViewCell else { return UICollectionViewCell() }
    cell.setConfigure(model)
    return cell
  }
  
  // MARK: internal function
  
}

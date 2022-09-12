//
//  CommunityReportViewController.swift
//  Archive
//
//  Created by hanwe on 2022/09/06.
//

import UIKit
import SnapKit
import ReactorKit
import RxCocoa
import RxSwift
import Then

class CommunityReportViewController: UIViewController, View, ActivityIndicatorable {
    
    // MARK: UI property
    
    private let mainBackgroundView = UIView().then {
        $0.backgroundColor = Gen.Colors.white.color
    }
    
    private let mainContentsView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private let mainTitleLabel = UILabel().then {
        $0.font = .fonts(.header3)
        $0.textColor = Gen.Colors.gray01.color
        $0.text = "게시물을 신고하려는 이유를 알려주세요."
    }
    
    private lazy var tableView = UITableView().then {
        $0.backgroundColor = .clear
        $0.delegate = self
        $0.dataSource = self
        $0.separatorStyle = .none
        $0.register(CommunityReportTableViewCell.self, forCellReuseIdentifier: CommunityReportTableViewCell.identifier)
    }
    
    private lazy var closeBtn = UIButton().then {
        $0.setImageAllState(Gen.Images.xIcon.image)
        $0.addTarget(self, action: #selector(closeClicked), for: .touchUpInside)
    }
    
    // MARK: private property
    
    // MARK: property
    
    var disposeBag: DisposeBag = DisposeBag()
    
    // MARK: lifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        makeNavigationItems()
        self.title = "신고"
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
        
        self.mainContentsView.addSubview(self.mainTitleLabel)
        self.mainTitleLabel.snp.makeConstraints {
            $0.top.equalTo(self.mainContentsView).offset(19)
            $0.centerX.equalTo(self.mainContentsView)
        }
        
        self.mainContentsView.addSubview(self.tableView)
        self.tableView.snp.makeConstraints {
            $0.top.equalTo(self.mainTitleLabel.snp.bottom).offset(11)
            $0.leading.trailing.bottom.equalTo(self.mainContentsView)
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
        
        self.tableView.rx.itemSelected
            .subscribe(onNext: { index in
                reactor.action.onNext(.report(archiveId: reactor.currentState.detailArchive.archiveInfo.archiveId,
                                              reason: ReportReason.getItemAtIndex(index.row)))
            })
            .disposed(by: self.disposeBag)
        
    }
    
    deinit {
        print("\(self) deinit")
    }
    
    // MARK: private func
    
    private func makeNavigationItems() {
        let closeItem = UIBarButtonItem.init(customView: self.closeBtn)
        let rightItems: [UIBarButtonItem] = [closeItem]
        
        self.navigationController?.navigationBar.topItem?.rightBarButtonItems = rightItems
    }
    
    @objc private func closeClicked() {
        self.dismiss(animated: true)
    }
    
    // MARK: func

}

extension CommunityReportViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ReportReason.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: CommunityReportTableViewCell = tableView.dequeueReusableCell(withIdentifier: CommunityReportTableViewCell.identifier, for: indexPath) as? CommunityReportTableViewCell else {
            return UITableViewCell()
        }
        cell.infoData = ReportReason.getItemAtIndex(indexPath.row).localizaedValue
        if cell.selectedBackgroundView == nil {
            let backgroundView = UIView()
            cell.selectedBackgroundView = backgroundView
        }
        cell.selectedBackgroundView?.backgroundColor = Gen.Colors.gray06.color
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    
}

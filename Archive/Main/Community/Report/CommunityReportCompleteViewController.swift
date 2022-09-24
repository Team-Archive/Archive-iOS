//
//  CommunityReportCompleteViewController.swift
//  Archive
//
//  Created by hanwe on 2022/09/24.
//

import UIKit
import SnapKit
import ReactorKit
import RxCocoa
import RxSwift
import Then

class CommunityReportCompleteViewController: UIViewController, View, ActivityIndicatorable {
    
    // MARK: UI property
    
    private let mainBackgroundView = UIView().then {
        $0.backgroundColor = Gen.Colors.white.color
    }
    
    private let mainContentsView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private lazy var closeBtn = UIButton().then {
        $0.setImageAllState(Gen.Images.xIcon.image)
        $0.addTarget(self, action: #selector(closeClicked), for: .touchUpInside)
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .fonts(.header3)
        $0.textColor = Gen.Colors.gray01.color
        $0.text = "이 게시물을 신고해주셔서 감사합니다."
        $0.numberOfLines = 10
    }
    
    private let subTitleLabel = UILabel().then {
        $0.font = .fonts(.body)
        $0.textColor = Gen.Colors.gray01.color
        $0.text = "회원님의 소중한 의견은 아카이브 커뮤니티를 안전하게\n유지하는 데 도움이 됩니다."
        $0.numberOfLines = 10
    }
    
    private lazy var confirmBtn = ConfirmBtn().then {
        $0.setTitleAllState("확인")
        $0.setTitleColor(Gen.Colors.white.color, for: .normal)
        $0.setTitleColor(Gen.Colors.gray01.color, for: .highlighted)
        $0.addTarget(self, action: #selector(confirmClicked), for: .touchUpInside)
    }
    
    // MARK: private property
    
    // MARK: property
    
    var disposeBag: DisposeBag = DisposeBag()
    
    // MARK: lifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "신고"
        makeNavigationItems()
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
        
        self.mainContentsView.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints {
            $0.top.equalTo(self.mainContentsView).offset(19)
            $0.leading.equalTo(32)
            $0.trailing.equalTo(-32)
        }
        
        self.mainContentsView.addSubview(self.subTitleLabel)
        self.subTitleLabel.snp.makeConstraints {
            $0.top.equalTo(self.titleLabel.snp.bottom).offset(21)
            $0.leading.equalTo(32)
            $0.trailing.equalTo(-32)
        }
        
        self.mainContentsView.addSubview(self.confirmBtn)
        self.confirmBtn.snp.makeConstraints {
            $0.bottom.equalTo(self.mainContentsView.snp.bottom).offset(-8)
            $0.leading.equalTo(32)
            $0.trailing.equalTo(-32)
            $0.height.equalTo(52)
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
        
    }
    
    deinit {
        print("\(self) deinit")
    }
    
    // MARK: private func
    
    private func makeNavigationItems() {
        let closeItem = UIBarButtonItem.init(customView: self.closeBtn)
        let rightItems: [UIBarButtonItem] = [closeItem]
        
        navigationItem.rightBarButtonItems = rightItems
    }
    
    @objc private func closeClicked() {
        self.dismiss(animated: true)
    }
    
    @objc private func confirmClicked() {
        self.dismiss(animated: true)
    }
    
    // MARK: func

}

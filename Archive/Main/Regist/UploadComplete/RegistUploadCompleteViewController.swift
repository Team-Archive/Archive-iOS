//
//  RegistUploadCompleteViewController.swift
//  Archive
//
//  Created by hanwe on 2022/08/28.
//

import UIKit
import Then
import SnapKit
import RxCocoa
import RxSwift
import ReactorKit

class RegistUploadCompleteViewController: UIViewController, View {
    
    // MARK: UI Property
    
    private let mainBackgroundView = UIView().then {
        $0.backgroundColor = Gen.Colors.white.color
    }
    
    private let scrollContainerView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private let scrollView = UIScrollView().then {
        $0.backgroundColor = .clear
    }
    
    private let mainContentsView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private lazy var closeBtn = UIButton().then {
        $0.setImageAllState(Gen.Images.xIcon.image)
        $0.addTarget(self, action: #selector(close), for: .touchUpInside)
    }
    
    private lazy var titleLabel = UILabel().then {
        $0.font = .fonts(.header2)
        $0.textColor = Gen.Colors.gray01.color
        $0.numberOfLines = 2
        $0.text = "이번 달에 \(self.thisMonthRegistCnt + 1)개의 전시를\n기록하셨네요!"
        $0.textAlignment = .center
    }
    
    private let subTitleLabel = UILabel().then {
        $0.font = .fonts(.subTitle)
        $0.textColor = Gen.Colors.gray01.color
        $0.numberOfLines = 1
        $0.text = "기록한 아카이브를 공유해보세요."
        $0.textAlignment = .center
    }
    
    private let buttonContainerView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private lazy var shareInstagramBtn = UIButton().then {
        $0.setImageAllState(Gen.Images.instaShare.image)
        $0.addTarget(self, action: #selector(shareInstagramAction), for: .touchUpInside)
    }
    
    private lazy var saveToAlbumBtn = UIButton().then {
        $0.setImageAllState(Gen.Images.download.image)
        $0.addTarget(self, action: #selector(saveImageAction), for: .touchUpInside)
    }
    
    private let lineImageView = UIImageView().then {
        $0.image = Gen.Images.line.image
    }
    
    private let ticketImageView = UIImageView().then {
        $0.image = Gen.Images.ticket.image
    }
    
    // MARK: private property
    
    private let thisMonthRegistCnt: Int
    
    // MARK: internal property
    
    var disposeBag: DisposeBag = DisposeBag()
    
    // MARK: life cycle
    
    init(reactor: RegistReactor, thisMonthRegistCnt: Int) {
        self.thisMonthRegistCnt = thisMonthRegistCnt
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        self.view.addSubview(self.mainBackgroundView)
        self.mainBackgroundView.snp.makeConstraints {
            $0.edges.equalTo(self.view)
        }
        
        let safeGuide = self.view.safeAreaLayoutGuide
        
        self.view.addSubview(self.scrollContainerView)
        self.scrollContainerView.snp.makeConstraints {
            $0.edges.equalTo(safeGuide)
        }
        
        self.scrollContainerView.addSubview(self.scrollView)
        self.scrollView.snp.makeConstraints {
            $0.edges.equalTo(self.scrollContainerView)
        }
        
        self.scrollView.addSubview(self.mainContentsView)
        self.mainContentsView.snp.makeConstraints {
            $0.edges.equalTo(self.scrollView).priority(750)
            $0.width.equalTo(self.scrollView).priority(1000)
        }
        
        self.mainContentsView.addSubview(self.closeBtn)
        self.closeBtn.snp.makeConstraints {
            $0.top.equalTo(self.mainContentsView)
            $0.trailing.equalTo(self.mainContentsView).offset(-20)
            $0.width.height.equalTo(36)
        }
        
        self.mainContentsView.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints {
            $0.top.equalTo(self.closeBtn.snp.bottom).offset(14)
            $0.leading.trailing.equalTo(self.mainContentsView)
        }
        
        self.mainContentsView.addSubview(self.subTitleLabel)
        self.subTitleLabel.snp.makeConstraints {
            $0.top.equalTo(self.titleLabel.snp.bottom).offset(24)
            $0.leading.trailing.equalTo(self.mainContentsView)
        }
        
        self.mainContentsView.addSubview(self.buttonContainerView)
        self.buttonContainerView.snp.makeConstraints {
            $0.top.equalTo(self.subTitleLabel.snp.bottom).offset(28)
            $0.centerX.equalTo(self.mainContentsView)
        }
        
        self.buttonContainerView.addSubview(self.saveToAlbumBtn)
        self.saveToAlbumBtn.snp.makeConstraints {
            $0.top.leading.bottom.equalTo(self.buttonContainerView)
            $0.width.height.equalTo(56)
        }
        
        self.buttonContainerView.addSubview(self.shareInstagramBtn)
        self.shareInstagramBtn.snp.makeConstraints {
            $0.centerY.equalTo(self.saveToAlbumBtn)
            $0.leading.equalTo(self.saveToAlbumBtn.snp.trailing).offset(20)
            $0.trailing.equalTo(self.buttonContainerView)
            $0.width.height.equalTo(56)
        }
        
        self.mainContentsView.addSubview(self.lineImageView)
        self.lineImageView.snp.makeConstraints {
            $0.top.equalTo(self.buttonContainerView.snp.bottom).offset(55)
            $0.leading.trailing.equalTo(self.mainContentsView)
            $0.height.equalTo(1)
        }
        
        self.mainContentsView.addSubview(self.ticketImageView)
        self.ticketImageView.snp.makeConstraints {
            $0.top.equalTo(self.lineImageView.snp.bottom).offset(49)
            $0.centerX.equalTo(self.mainContentsView)
            $0.width.equalTo(175)
            $0.height.equalTo(294)
            $0.bottom.equalTo(self.mainContentsView.snp.bottom).offset(-20)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    deinit {
        print("\(self) deinit")
    }
    
    func bind(reactor: RegistReactor) {
        
    }
    
    // MARK: private func
    
    @objc private func close() {
        self.dismiss(animated: false, completion: { [weak self] in
            self?.reactor?.action.onNext(.registIsComplete)
        })
    }
    
    @objc private func shareInstagramAction() {
        GAModule.sendEventLogToGA(.shareInstagramFromRegist)
        DispatchQueue.main.async { [weak self] in
            guard let cardView: ShareCardView = self?.makeCardView() else { return }
            InstagramStoryShareManager.shared.share(view: cardView, backgroundTopColor: cardView.topBackgroundColor, backgroundBottomColor: cardView.bottomBackgroundColor, completion: { _ in
                
            }, failure: { err in
                ArchiveToastView.shared.show(message: err, completeHandler: nil)
            })
        }
    }
    
    @objc private func saveImageAction() {
        guard let cardView: ShareCardView = self.makeCardView() else { return }
        guard let activityViewController = CardShareManager.shared.share(view: cardView) else { return }
        activityViewController.isModalInPresentation = true
        activityViewController.excludedActivityTypes = [.airDrop, .message]
        let fakeViewController = UIViewController()
        fakeViewController.modalPresentationStyle = .overFullScreen

        activityViewController.completionWithItemsHandler = { [weak fakeViewController] _, isSaved, _, _ in
            if let presentingViewController = fakeViewController?.presentingViewController {
                presentingViewController.dismiss(animated: false, completion: nil)
            } else {
                fakeViewController?.dismiss(animated: false, completion: nil)
            }
            if isSaved {
                ArchiveToastView.shared.show(message: "이미지 저장 완료", completeHandler: nil)
            }
        }
        self.present(fakeViewController, animated: true) { [weak fakeViewController] in
            fakeViewController?.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    private func makeCardView() -> ShareCardView? {
        guard let cardView: ShareCardView = ShareCardView.instance() else { return nil }
        cardView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 1.73)
        cardView.setInfoData(emotion: self.reactor?.currentState.emotion ?? .pleasant,
                             thumbnailImage: self.reactor?.currentState.imageInfo.images[0].image ?? UIImage(),
                             eventName: self.reactor?.currentState.archiveName ?? "",
                             date: self.reactor?.currentState.visitDate ?? "",
                             coverType: (self.reactor?.currentState.isCoverUsing ?? true) ? .cover : .image)
        return cardView
    }
    
    // MARK: internal func
    
    
}

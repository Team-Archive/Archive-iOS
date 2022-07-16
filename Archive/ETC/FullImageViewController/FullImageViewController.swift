//
//  FullImageViewController.swift
//  Archive
//
//  Created by hanwe on 2022/07/16.
//

import UIKit
import Kingfisher
import SnapKit
import Then

class FullImageViewController: UIViewController {
    
    // MARK: UI
    
    private let mainBackgroundView = UIView().then {
        $0.backgroundColor = Gen.Colors.white.color
    }
    
    private let mainContentsView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private let scrollVew = UIScrollView().then {
        $0.backgroundColor = .clear
    }
    
    private lazy var imageView = UIImageView().then {
        $0.backgroundColor = .clear
    }
    
    private lazy var closeBtn = UIButton().then {
        $0.setImageAllState(Gen.Images.xIcon.image)
        $0.addTarget(self, action: #selector(closeClicked), for: .touchUpInside)
    }
    
    // MARK: private property
    
    private let imageUrl: URL
    
    // MARK: internal property
    
    // MARK: lifeCycle
    
    init(url: URL) {
        self.imageUrl = url
        super.init(nibName: nil, bundle: nil)
        ImageCache.default.clearCache(completion: { [weak self] in
            KingfisherManager.shared.retrieveImage(with: url, completionHandler: { [weak self] result in
                switch result {
                case .success(let imageResult):
                    let width = UIScreen.main.bounds.width
                    let ratio = width/imageResult.image.size.width
                    let height = ratio * imageResult.image.size.height
                    DispatchQueue.main.async { [weak self] in
                        self?.scrollVew.contentSize = CGSize(width: width, height: height)
                        self?.imageView.kf.setImage(with: url)
                        self?.imageView.snp.updateConstraints {
                            $0.width.equalTo(width)
                            $0.height.equalTo(height)
                        }
                    }
                case .failure(let err):
                    CommonAlertView.shared.show(message: "이미지 로드 실패\n\(err.localizedDescription)", btnText: "확인", confirmHandler: { [weak self] in
                        CommonAlertView.shared.hide()
                        self?.dismiss(animated: true)
                    })
                }
            })
        })
    }
    
    deinit {
        print("\(self) deinit")
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
        
        self.view.addSubview(self.mainContentsView)
        let safeGuide = self.view.safeAreaLayoutGuide
        self.mainContentsView.snp.makeConstraints {
            $0.edges.equalTo(safeGuide)
        }
        
        self.mainContentsView.addSubview(self.scrollVew)
        self.scrollVew.snp.makeConstraints {
            $0.edges.equalTo(self.mainContentsView)
        }
        
        self.scrollVew.addSubview(self.imageView)
        self.imageView.snp.remakeConstraints {
            $0.width.height.equalTo(100)
            $0.centerX.equalTo(self.scrollVew.snp.centerX)
            $0.top.equalTo(self.scrollVew.snp.top)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeNavigationItems()
    }
    
    // MARK: private function
    
    private func makeNavigationItems() {
        let closeItem = UIBarButtonItem.init(customView: self.closeBtn)
        let rightItems: [UIBarButtonItem] = [closeItem]
        self.navigationController?.navigationBar.topItem?.rightBarButtonItems = rightItems
    }
    
    // MARK: internal function
    
    // MARK: action
    
    @objc private func closeClicked() {
        self.dismiss(animated: true)
    }
    

}

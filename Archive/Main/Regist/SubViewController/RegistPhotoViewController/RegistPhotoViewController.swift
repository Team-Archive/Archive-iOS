//
//  RegistPhotoViewController.swift
//  Archive
//
//  Created by hanwe on 2022/08/15.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa
import SnapKit
import Then
import Photos
import CropViewController

class RegistPhotoViewController: UIViewController, View {
    
    // MARK: UIProperty
    
    private let mainBackgroundView = UIView().then {
        $0.backgroundColor = Gen.Colors.white.color
    }
    
    private let mainContentsView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private let imageThumbnailContainerView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private let thumbnailImageView = UIImageView().then {
        $0.backgroundColor = .clear
        $0.contentMode = .scaleAspectFit
    }
    
    private let imageAlbumContainerView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    // MARK: private property
    
    private var confirmBtn: UIBarButtonItem?
    private let photoUsecase = PhotoUsecase()
    
    // MARK: internal property
    
    var disposeBag: DisposeBag = DisposeBag()
    
    // MARK: lifeCycle
    
    init(reactor: RegistPhotoReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("\(self) deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeConfirmBtn()
        makeCancelBtn()
    }
    
    override func loadView() {
        super.loadView()
        setup()
    }
    
    func bind(reactor: RegistPhotoReactor) {
        reactor.state
            .map { $0.thumbnailImage }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: UIImage())
            .drive(onNext: { [weak self] image in
                self?.thumbnailImageView.image = image
            })
            .disposed(by: self.disposeBag)
    }
    
    // MARK: private function
    
    private func setup() {
        self.view.addSubview(self.mainBackgroundView)
        self.mainBackgroundView.snp.makeConstraints {
            $0.edges.equalTo(self.view)
        }
        
        self.view.addSubview(self.mainContentsView)
        let safeGuide = self.view.safeAreaLayoutGuide
        self.mainContentsView.snp.makeConstraints {
            $0.edges.equalTo(safeGuide)
        }
        
        self.mainContentsView.addSubview(self.imageThumbnailContainerView)
        self.imageThumbnailContainerView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(self.mainContentsView)
            $0.height.equalTo(UIScreen.main.bounds.width)
        }
        
        self.imageThumbnailContainerView.addSubview(self.thumbnailImageView)
        self.thumbnailImageView.snp.makeConstraints {
            $0.edges.equalTo(self.imageThumbnailContainerView)
        }
        
        self.mainContentsView.addSubview(self.imageAlbumContainerView)
        self.imageAlbumContainerView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalTo(self.mainContentsView)
            $0.top.equalTo(self.imageThumbnailContainerView.snp.bottom)
        }
        
        if let albumView = HWPhotoListFromAlbumView.loadFromNibNamed(nibNamed: "HWPhotoListFromAlbumView") {
            albumView.delegate = self
            albumView.selectType = .multi
            self.imageAlbumContainerView.addSubview(albumView)
            albumView.snp.makeConstraints { (make) in
                make.edges.equalTo(self.imageAlbumContainerView)
            }
        }
        
    }
    
    private func makeConfirmBtn() {
        self.confirmBtn = UIBarButtonItem(title: "선택", style: .plain, target: self, action: #selector(confirmAction(_:)))
        setConfirmBtnColor(Gen.Colors.gray04.color)
        self.navigationController?.navigationBar.topItem?.rightBarButtonItems?.removeAll()
        self.navigationController?.navigationBar.topItem?.rightBarButtonItem = confirmBtn
    }
    
    private func setConfirmBtnColor(_ color: UIColor) {
        DispatchQueue.main.async { [weak self] in
            self?.confirmBtn?.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.fonts(.button), NSAttributedString.Key.foregroundColor: color], for: .normal)
            self?.confirmBtn?.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.fonts(.button), NSAttributedString.Key.foregroundColor: color], for: .highlighted)
        }
    }
    
    private func setConfirmBtnTitle(_ title: String) {
        DispatchQueue.main.async { [weak self] in
            self?.confirmBtn?.title = title
        }
    }
    
    @objc private func confirmAction(_ sender: UIButton) {
        print("얍")
    }
    
    private func makeCancelBtn() {
        let cancelBtn: UIBarButtonItem = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(cancelAction(_:)))
        setConfirmBtnColor(Gen.Colors.black.color)
        self.navigationController?.navigationBar.topItem?.leftBarButtonItems?.removeAll()
        self.navigationController?.navigationBar.topItem?.leftBarButtonItem = cancelBtn
    }
    
    @objc private func cancelAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: internal function

}

extension RegistPhotoViewController: HWPhotoListFromAlbumViewDelegate {
    func changeFocusImg(focusIndex: Int) {
        
    }
    
    func selectedImgsFromAlbum(selectedImg: [PHAsset: PhotoFromAlbumModel], focusIndexAsset: PHAsset) {
        if selectedImg.count == 0 {
            self.setConfirmBtnTitle("선택")
            self.setConfirmBtnColor(Gen.Colors.gray04.color)
        } else {
            self.setConfirmBtnTitle("선택(\(selectedImg.count))")
            self.setConfirmBtnColor(Gen.Colors.black.color)
        }
        self.reactor?.action.onNext(.setImageInfos(selectedImg))
        self.reactor?.action.onNext(.setThumbnailImage(focusIndexAsset))
    }
}

//
//  EditProfileViewController.swift
//  Archive
//
//  Created by hanwe on 2022/08/06.
//

import UIKit
import SnapKit
import ReactorKit
import RxCocoa
import Then
import AVFoundation
import CropViewController

class EditProfileViewController: UIViewController, View, ActivityIndicatorable {
    
    // MARK: UI property
    
    private let mainBackgroundView = UIView().then {
        $0.backgroundColor = Gen.Colors.white.color
    }
    
    private let mainContentsView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private let profileImageContainerView = UIView().then {
        $0.backgroundColor = .clear
        $0.layer.cornerRadius = 31
        $0.layer.masksToBounds = true
    }
    
    private let profileImageView = UIImageView().then {
        $0.backgroundColor = .clear
        $0.image = Gen.Images.userImagePlaceHolder.image
    }
    
    private let profileImageEditImageView = UIImageView().then {
        $0.image = Gen.Images.editProfile.image
    }
    
    private lazy var profileEditBtn = UIButton().then {
        $0.addTarget(self, action: #selector(photoEditAction), for: .touchUpInside)
    }
    
    private let nicknameTextField = ArchiveCheckTextField(originValue: LogInManager.shared.nickname,
                                                          placeHolder: "새로운 닉네임을 설정해보세요!",
                                                          checkBtnTitle: "중복 확인").then {
        $0.backgroundColor = .white
    }
    
    private let duplicatedNicknameWarningLabel = UILabel().then {
        $0.font = .fonts(.body)
        $0.textColor = Gen.Colors.gray02.color
    }
    
    private let confirmBtn = ArchiveConfirmButton().then {
        $0.setTitleAllState("프로필 변경")
    }
    
    // MARK: private property
    
    private lazy var photoPicker = UIImagePickerController().then {
        $0.delegate = self
        $0.sourceType = .savedPhotosAlbum
        $0.allowsEditing = false
    }
    
    // MARK: property
    
    var disposeBag: DisposeBag = DisposeBag()
    
    // MARK: lifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    init(reactor: EditProfileReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParent {
            self.reactor?.action.onNext(.endFlow)
        }
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
        
        self.mainContentsView.addSubview(self.profileImageContainerView)
        self.profileImageContainerView.snp.makeConstraints {
            $0.top.equalTo(self.mainContentsView).offset(20)
            $0.width.height.equalTo(62)
            $0.centerX.equalTo(self.mainContentsView)
        }
        
        self.profileImageContainerView.addSubview(self.profileImageView)
        self.profileImageView.snp.makeConstraints {
            $0.edges.equalTo(self.profileImageContainerView)
        }
        
        self.mainContentsView.addSubview(self.profileImageEditImageView)
        self.profileImageEditImageView.snp.makeConstraints {
            $0.width.height.equalTo(20)
            $0.trailing.bottom.equalTo(self.profileImageContainerView)
        }
        
        self.profileImageContainerView.addSubview(self.profileEditBtn)
        self.profileEditBtn.snp.makeConstraints {
            $0.edges.equalTo(self.profileImageContainerView)
        }
        
        self.mainContentsView.addSubview(self.nicknameTextField)
        self.nicknameTextField.snp.makeConstraints {
            $0.top.equalTo(self.profileImageContainerView.snp.bottom).offset(20)
            $0.leading.equalTo(self.mainContentsView).offset(32)
            $0.trailing.equalTo(self.mainContentsView).offset(-32)
            $0.height.equalTo(52)
        }
        
        self.mainContentsView.addSubview(self.duplicatedNicknameWarningLabel)
        self.duplicatedNicknameWarningLabel.snp.makeConstraints {
            $0.top.equalTo(self.nicknameTextField.snp.bottom).offset(10)
            $0.leading.equalTo(self.mainContentsView).offset(32)
            $0.trailing.equalTo(self.mainContentsView).offset(-32)
        }
        self.duplicatedNicknameWarningLabel.alpha = 0
        
        self.mainContentsView.addSubview(self.confirmBtn)
        self.confirmBtn.snp.makeConstraints {
            $0.top.equalTo(self.duplicatedNicknameWarningLabel.snp.bottom).offset(31)
            $0.height.equalTo(52)
            $0.leading.equalTo(self.mainContentsView).offset(32)
            $0.trailing.equalTo(self.mainContentsView).offset(-32)
        }
        self.confirmBtn.isEnabled = false
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(reactor: EditProfileReactor) {
        
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
        
        reactor.state
            .map { $0.isEnableConfirmBtn }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] isEnable in
                self?.confirmBtn.isEnabled = isEnable
            })
            .disposed(by: self.disposeBag)
        
        reactor.state
            .map { $0.isDuplicatedNickName }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: nil)
            .drive(onNext: { [weak self] isDuplicated in
                guard let isDuplicated = isDuplicated else { self?.duplicatedNicknameWarningLabel.alpha = 0 ; return }
                self?.duplicatedNicknameWarningLabel.alpha = 1
                if isDuplicated {
                    self?.duplicatedNicknameWarningLabel.text = "이미 사용 중인 닉네임입니다."
                } else {
                    self?.duplicatedNicknameWarningLabel.text = "사용할 수 있는 닉네임입니다."
                }
            })
            .disposed(by: self.disposeBag)
        
        self.nicknameTextField.rx.check
            .asDriver(onErrorJustReturn: "")
            .drive(onNext: { [weak self] nickName in
                reactor.action.onNext(.checkIsDuplicatedNickName(nickName))
            })
            .disposed(by: self.disposeBag)
        
        self.nicknameTextField.rx.text
            .asDriver(onErrorJustReturn: "")
            .drive(onNext: { [weak self] text in
                reactor.action.onNext(.changedNickNameText)
            })
            .disposed(by: self.disposeBag)
        
        reactor.moveToConfig
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] in
                CommonAlertView.shared.show(message: "프로필 사진을 선택하려면 사진 라이브러리 접근권한이 필요합니다.", subMessage: nil, btnText: "확인", hapticType: .warning, confirmHandler: {
                    Util.moveToSetting()
                    CommonAlertView.shared.hide(nil)
                })
            })
            .disposed(by: self.disposeBag)
        
        reactor.photoAccessAuthSuccess
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] in
                self?.present(self?.photoPicker ?? UIViewController(), animated: true)
            })
            .disposed(by: self.disposeBag)
        
        self.confirmBtn.rx.tap
            .asDriver()
            .drive(onNext: {
                reactor.action.onNext(.updateProfile)
            })
            .disposed(by: self.disposeBag)
        
        reactor.updateProfileComplete
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: self.disposeBag)
        
        
    }
    
    deinit {
        print("\(self) deinit")
    }
    
    // MARK: private func
    
    @objc private func photoEditAction() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let takePhotoAction: UIAlertAction = UIAlertAction(title: "사진 찍기", style: .default) { [weak self] (takeAPhoto) in
            let vc = UIImagePickerController()
            vc.sourceType = .camera
            vc.allowsEditing = true
            vc.delegate = self
            self?.present(vc, animated: true)
            // TODO: 이거 테스트하려면 XCode 업데이트 해야함..
        }
        let selectFromLibraryAction: UIAlertAction = UIAlertAction(title: "라이브러리에서 선택", style: .default) { selectFromLibrary in
            self.reactor?.action.onNext(.requestPhotoAccessAuth)
        }
        alert.view.tintColor = .black
        alert.addAction(takePhotoAction)
        alert.addAction(selectFromLibraryAction)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
//    func checkCameraPermission(){
//        AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
//            if granted {
//                print("Camera: 권한 허용")
//            } else {
//                print("Camera: 권한 거부")
//            }
//        })
//    }
    
    private func showImageEditView(image: UIImage) {
        let cropViewController: CropViewController = CropViewController(croppingStyle: .circular, image: image)
        cropViewController.delegate = self
        cropViewController.doneButtonTitle = "확인"
        cropViewController.doneButtonColor = Gen.Colors.white.color
        cropViewController.cancelButtonTitle = "취소"
        cropViewController.cancelButtonColor = Gen.Colors.white.color
        self.present(cropViewController, animated: true, completion: nil)
    }
    
    // MARK: func

}

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: false)

//        guard let image = info[.editedImage] as? UIImage else {
//            print("No image found")
//            return
//        }
        
        guard let image = info[.originalImage] as? UIImage else { print("No image found from library") ; return }
        DispatchQueue.main.async { [weak self] in
            self?.showImageEditView(image: image)
        }
    }
}

extension EditProfileViewController: CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        DispatchQueue.main.async { [weak self] in
            cropViewController.dismiss(animated: true, completion: { [weak self] in
//                self?.reactor?.action.onNext(.setCropedImage(image))
                guard let data = image.pngData() else { return }
                self?.reactor?.action.onNext(.setProfileImageData(data))
                self?.profileImageView.image = image
            })
        }
    }
}

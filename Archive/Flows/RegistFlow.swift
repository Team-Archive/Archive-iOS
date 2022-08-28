//
//  RegistFlow.swift
//  Archive
//
//  Created by hanwe on 2022/08/28.
//

import UIKit
import RxFlow

class RegistFlow: Flow {
    
    // MARK: private property
    
    // MARK: internal property
    
    var root: Presentable {
        return rootViewController
    }
    
    let rootViewController: UINavigationController
    let reactor: RegistReactor
    
    weak var registUploadViewController: RegistUploadViewController?
    
    // MARK: lifeCycle
    
    init(rootViewController: UINavigationController, reacoter: RegistReactor) {
        self.rootViewController = rootViewController
        self.reactor = reacoter
    }
    
    // MARK: private function
    
    private func registUploadShow() {
        let vc = RegistUploadViewController(reactor: self.reactor)
        vc.modalPresentationStyle = .fullScreen
        self.registUploadViewController = vc
        self.rootViewController.present(vc, animated: false)
    }
    
    private func registCompleteShow(thisMonthRegistCnt: Int) {
        if let registUploadViewController = registUploadViewController {
            let reactor = self.reactor
            registUploadViewController.stopAnimation()
            registUploadViewController.dismiss(animated: false, completion: { [weak self] in
                let vc = RegistUploadCompleteViewController(reactor: reactor,
                                                            thisMonthRegistCnt: thisMonthRegistCnt)
                vc.modalPresentationStyle = .fullScreen
                self?.rootViewController.present(vc, animated: false)
            })
            print("얍")
        } else {
            let vc = RegistUploadViewController(reactor: self.reactor)
            vc.modalPresentationStyle = .fullScreen
            self.rootViewController.present(vc, animated: false)
        }
    }
    
    // MARK: internal function
    
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? ArchiveStep else { return .none }
        switch step {
        case .registIsRequired:
            return .none
        case .registUploadIsRequired:
            registUploadShow()
            return .none
        case .registCompleteIsRequired(let cnt):
            registCompleteShow(thisMonthRegistCnt: cnt)
            return .none
        default:
            return .none
        }
    }
}

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
    
    // MARK: lifeCycle
    
    init(rootViewController: UINavigationController, reacoter: RegistReactor) {
        self.rootViewController = rootViewController
        self.reactor = reacoter
    }
    
    // MARK: private function
    
    private func registUploadShow() {
        let vc = RegistUploadViewController(reactor: self.reactor)
        vc.modalPresentationStyle = .fullScreen
        self.rootViewController.present(vc, animated: false)
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
        default:
            return .none
        }
    }
}

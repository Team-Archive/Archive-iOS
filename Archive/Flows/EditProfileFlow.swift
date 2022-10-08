//
//  EditProfileFlow.swift
//  Archive
//
//  Created by hanwe on 2022/09/24.
//

import UIKit
import RxFlow

class EditProfileFlow: Flow {
    
    // MARK: private property
    
    // MARK: internal property
    
    var root: Presentable {
        return rootViewController
    }
    
    let rootViewController: UINavigationController
    
    // MARK: lifeCycle
    
    init(rootViewController: UINavigationController) {
        self.rootViewController = rootViewController
    }
    
    // MARK: private function
    
    // MARK: internal function
    
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? ArchiveStep else { return .none }
        switch step {
        case .editProfileIsComplete:
            return .end(forwardToParentFlowWithStep: ArchiveStep.editProfileIsComplete)
        default:
            return .none
        }
    }
}

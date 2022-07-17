//
//  Tab.swift
//  Archive
//
//  Created by hanwe on 2022/05/14.
//

import UIKit
import RxFlow

class TabViewControllers {
    let homeViewController: HomeViewController
    let homeStepper: Stepper
    let dummyRecordViewController: DummyRecordViewController
    let communityViewController: CommunityViewController
    let communityStepper: Stepper
    let myPageViewController: MyPageViewController
    let myPageStepper: Stepper
    
    init(homeViewController: HomeViewController, homeStepper: Stepper, dummyRecordViewController: DummyRecordViewController, communityViewController: CommunityViewController, communityStepper: Stepper, myPageViewController: MyPageViewController, myPageStepper: Stepper) {
        self.homeViewController = homeViewController
        self.dummyRecordViewController = dummyRecordViewController
        self.communityViewController = communityViewController
        self.myPageViewController = myPageViewController
        
        self.homeStepper = homeStepper
        self.communityStepper = communityStepper
        self.myPageStepper = myPageStepper
    }
}

protocol MajorTabViewController where Self: UIViewController {
    func willTabSeleted()
    func didTabSeleted()
    func willUnselected()
}

enum Tab {
    case none
    case home
    case record
    case community
    case myPage
}

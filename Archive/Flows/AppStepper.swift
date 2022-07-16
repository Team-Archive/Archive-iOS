//
//  AppStepper.swift
//  Archive
//
//  Created by TTOzzi on 2021/10/14.
//

import RxRelay
import RxFlow

final class AppStepper: Stepper {

    let steps = PublishRelay<Step>()

    var initialStep: Step {
        return ArchiveStep.splashIsRequired
    }
}

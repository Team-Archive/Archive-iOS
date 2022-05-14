//
//  CommunityReactor.swift
//  Archive
//
//  Created by hanwe on 2022/05/14.
//

import RxSwift
import RxRelay
import RxFlow

class CommunityReactor: Stepper {
    
    let steps = PublishRelay<Step>()
    
}

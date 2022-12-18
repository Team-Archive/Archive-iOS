//
//  ArchiveStatus.swift
//  Archive
//
//  Created by hanwe on 2022/05/06.
//

import UIKit
import RxSwift

class ArchiveStatus: NSObject {
    
    enum Mode {
        case normal
        case debug(url: String?)
    }
    
    // MARK: private property
    
    // MARK: internal property
    
    private(set) var mode: Mode = .normal
    private(set) var isShownFakeSplash: Bool = false
    var currentArchives: BehaviorSubject<[ArchiveInfo]> = .init(value: [])
    
    // MARK: lifeCycle
    
    static let shared: ArchiveStatus = {
        let instance = ArchiveStatus()
        return instance
    }()
    
    // MARK: private function
    
    // MARK: internal function
    
    func changeMode(mode: Mode, password: String) -> Result<Mode, ArchiveError> {
        if password.lowercased() == CommonDefine.passwordForDebugCheatKey.lowercased() {
            self.mode = mode
            return .success(mode)
        } else {
            return .failure(.init(.commonError))
        }
    }
    
    func runFakeSplash() {
        self.isShownFakeSplash = true
    }

}

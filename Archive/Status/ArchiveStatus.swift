//
//  ArchiveStatus.swift
//  Archive
//
//  Created by hanwe on 2022/05/06.
//

import UIKit

class ArchiveStatus: NSObject {
    
    enum Mode {
        case normal
        case debug
    }
    
    // MARK: private property
    
    // MARK: internal property
    
    private(set) var mode: Mode = .normal
    
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

}

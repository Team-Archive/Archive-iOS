//
//  IntExtension.swift
//  Archive
//
//  Created by hanwe on 2022/06/25.
//

extension Int {
    var likeCntToArchiveLikeCnt: String {
        var returnValue: String = ""
        
        if self >= 1000 {
            returnValue = "999+"
        } else {
            returnValue = "\(self)"
        }
        
        return returnValue
    }
}

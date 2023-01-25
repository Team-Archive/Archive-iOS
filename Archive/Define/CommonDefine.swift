//
//  CommonDefine.swift
//  Archive
//
//  Created by hanwe on 2021/12/26.
//

import UIKit

enum Direction {
    case left
    case right
    case top
    case bottom
}

enum CoverType: String, Codable, CaseIterable {
    case cover = "EMOTION_COVER"
    case image = "NO_COVER"
    
    static func coverTypeFromRawValue(_ rawValue: String) -> CoverType? {
        var returnValue: CoverType?
        for item in CoverType.allCases where item.rawValue == rawValue {
            returnValue = item
        }
        return returnValue
    }
}

class CommonDefine: NSObject {
    static let kakaoAppKey: String = "147a5c186ee0f5fdc58244b704165132"
    static let devApiServer: String = "https://archive-ticket.site/dev" // 개발
    static let passwordForDebugCheatKey: String = "goLang"
    static let privacyUrl = "https://scarce-barge-103.notion.site/0370a9320f2d4c2286db8d276d378712"
    static let termsUrl = "https://scarce-barge-103.notion.site/f6b1cf943c074182a69fe8433df2eca0"
    static let aboutArchiveUrl = "https://scarce-barge-103.notion.site/a9610a1fc3f6469499e33798bc6def00"
#if DEBUG
    static let apiServer: String = "https://archive-ticket.site/dev" // 개발
//    static let apiServer: String = "https://archive-ticket.site/prd" // 실서버
#else
    static let apiServer: String = "https://archive-ticket.site/prd"
#endif
    static let kakaoAPIServer: String = "https://kapi.kakao.com"
    
    
}



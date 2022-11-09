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

class CommonDefine: NSObject {
    static let kakaoAppKey: String = "147a5c186ee0f5fdc58244b704165132"
    static let devApiServer: String = "https://archive-ticket.site/dev" // 개발
    static let passwordForDebugCheatKey: String = "goLang"
    static let privacyUrl = "https://www.notion.so/0370a9320f2d4c2286db8d276d378712"
    static let termsUrl = "https://www.notion.so/f6b1cf943c074182a69fe8433df2eca0"
    static let aboutArchiveUrl = "https://www.notion.so/Preview-d2a89a612a694ec8a8fc180c8efb9c39"
#if DEBUG
    static let apiServer: String = "https://archive-ticket.site/dev" // 개발
//    static let apiServer: String = "https://archive-ticket.site/prd" // 실서버
#else
    static let apiServer: String = "https://archive-ticket.site/prd"
#endif
    static let kakaoAPIServer: String = "https://kapi.kakao.com"
    
    
}



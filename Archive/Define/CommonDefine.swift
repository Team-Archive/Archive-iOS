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
#if DEBUG
    static let apiServer: String = "https://archive-ticket.site/dev" // 개발
//    static let apiServer: String = "https://archive-ticket.site/prd" // 실서버
#else
    static let apiServer: String = "https://archive-ticket.site/prd"
#endif
    static let kakaoAPIServer: String = "https://kapi.kakao.com"
    
    
}



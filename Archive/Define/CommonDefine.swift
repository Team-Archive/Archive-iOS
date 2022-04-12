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
#if DEBUG
    static let apiServer: String = "http://13.124.85.216:8080"
#else
    static let apiServer: String = "http://3.38.66.239:8080"
#endif
    static let kakaoAPIServer: String = "https://kapi.kakao.com"
}

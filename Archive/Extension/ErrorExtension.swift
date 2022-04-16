//
//  ErrorExtension.swift
//  Archive
//
//  Created by hanwe on 2022/03/20.
//

import Moya
import SwiftyJSON

extension Error {
    func toResponseCode() -> Int {
        return (self as? MoyaError)?.response?.statusCode ?? -1
    }
}

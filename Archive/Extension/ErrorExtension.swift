//
//  ErrorExtension.swift
//  Archive
//
//  Created by hanwe on 2022/03/20.
//

import Moya
import SwiftyJSON

extension Error {
    
    var responseCode: Int {
        return (self as? MoyaError)?.response?.statusCode ?? -1
    }
    
    var archiveErrMsg: String {
        guard let moyaErrResponseData = (self as? MoyaError)?.response?.data else { return self.localizedDescription }
        guard let jsonMsg = try? JSON.init(data: moyaErrResponseData) else { return self.localizedDescription }
        return jsonMsg["code"].stringValue + "\n" + jsonMsg["message"].stringValue 
    }
    
}

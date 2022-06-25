//
//  ArchiveAPI.swift
//  Archive
//
//  Created by hanwe on 2021/11/22.
//

import Moya

enum ArchiveAPI {
    case uploadImage(_ image: UIImage)
    case registArchive(_ info: RecordData)
    case registEmail(_ param: RequestEmailParam)
    case loginEmail(_ param: LoginEmailParam)
    case logInWithOAuth(logInType: OAuthSignInType, token: String)
    case isDuplicatedEmail(_ eMail: String)
    case deleteArchive(archiveId: String)
    case getArchives
    case getDetailArchive(archiveId: String)
    case getCurrentUserInfo
    case withdrawal
    case getKakaoUserInfo(kakaoAccessToken: String)
    case sendTempPassword(email: String)
    case changePassword(eMail: String, beforePassword: String, newPassword: String)
    case getPublicArchives(sortBy: String, emotion: String?, lastSeenArchiveDateMilli: Int?, lastSeenArchiveId: Int?)
    case like(archiveId: Int)
    case unlike(archiveId: Int)
}
        
extension ArchiveAPI: TargetType {
    
    var baseURL: URL {
        var domain: String = ""
        if ArchiveStatus.shared.mode == .debug {
            domain = CommonDefine.devApiServer
        } else {
            domain = CommonDefine.apiServer
        }
        
        switch self {
        case .uploadImage, .registArchive, .registEmail, .loginEmail, .logInWithOAuth, .isDuplicatedEmail, .deleteArchive, .getArchives, .getDetailArchive, .getCurrentUserInfo, .withdrawal, .sendTempPassword, .changePassword, .getPublicArchives, .like, .unlike:
            return URL(string: domain)!
        case .getKakaoUserInfo:
            return URL(string: CommonDefine.kakaoAPIServer)!
        }
    }
    
    var path: String {
        switch self {
        case .uploadImage:
            return "/api/v1/archive/image/upload"
        case .registArchive:
            return "/api/v1/archive"
        case .registEmail:
            return "/api/v1/auth/register"
        case .loginEmail:
            return "/api/v1/auth/login"
        case .logInWithOAuth:
            return "/api/v1/auth/social"
        case .isDuplicatedEmail(let eMail):
            return "/api/v1/auth/email/" + eMail
        case .deleteArchive(let archiveId):
            return "/api/v1/archive/" + archiveId
        case .getArchives:
            return "/api/v1/archive"
        case .getDetailArchive(let archiveId):
            return "/api/v1/archive/" + archiveId
        case .getCurrentUserInfo:
            return "/api/v1/auth/info"
        case .withdrawal:
            return "/api/v1/auth/unregister"
        case .getKakaoUserInfo:
            return "/v2/user/me"
        case .sendTempPassword:
            return "api/v1/auth/password/temporary"
        case .changePassword:
            return "api/v1/auth/password/reset"
        case .getPublicArchives:
            return "/api/v2/archive/community"
        case .like(let archiveId):
            return "/api/v2/archive/\(archiveId)/like"
        case .unlike(let archiveId):
            return "/api/v2/archive/\(archiveId)/like"
        }
    }
    
    var method: Method {
        switch self {
        case .uploadImage:
            return .post
        case .registArchive:
            return .post
        case .registEmail:
            return .post
        case .loginEmail:
            return .post
        case .logInWithOAuth:
            return .post
        case .isDuplicatedEmail:
            return .get
        case .deleteArchive:
            return .delete
        case .getArchives:
            return .get
        case .getDetailArchive:
            return .get
        case .getCurrentUserInfo:
            return .get
        case .withdrawal:
            return .delete
        case .getKakaoUserInfo:
            return .get
        case .sendTempPassword:
            return .post
        case .changePassword:
            return .post
        case .getPublicArchives:
            return .get
        case .like:
            return .post
        case .unlike:
            return .delete
        }
    }
    
    var task: Task {
        switch self {
        case .uploadImage(let image):
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd-HH:mm:ss"
            let data: MultipartFormData = MultipartFormData(provider: .data(image.pngData()!), name: "image", fileName: "\(dateFormatter.string(from: Date())).jpeg", mimeType: "image/jpeg")
            return .uploadMultipart([data])
        case .registArchive(let infoData):
            return .requestJSONEncodable(infoData)
        case .registEmail(let param):
            return .requestJSONEncodable(param)
        case .loginEmail(let param):
            return .requestJSONEncodable(param)
        case .logInWithOAuth(let type, let token):
            return .requestParameters(parameters: ["providerAccessToken": token, "provider": type.rawValue], encoding: JSONEncoding.default)
        case .isDuplicatedEmail:
            return .requestPlain
        case .deleteArchive:
            return .requestPlain
        case .getArchives:
            return .requestPlain
        case .getDetailArchive:
            return .requestPlain
        case .getCurrentUserInfo:
            return .requestPlain
        case .withdrawal:
            return .requestPlain
        case .getKakaoUserInfo:
            return .requestPlain
        case .sendTempPassword(let email):
            return .requestParameters(parameters: ["email": email], encoding: JSONEncoding.default)
        case .changePassword(let eMail, let beforePassword, let newPassword):
            return .requestParameters(parameters: ["currentPassword": beforePassword, "email": eMail, "newPassword": newPassword], encoding: JSONEncoding.default)
        case .getPublicArchives(let sortBy, let emotion, let lastSeenArchiveDateMilli, let lastSeenArchiveId):
            let param: [String: Any] = {
                var returnValue: [String: Any] = [String: Any]()
                returnValue["sortType"] = sortBy
                if let emotion = emotion {
                    returnValue["emotion"] = emotion
                }
                if let lastSeenArchiveDateMilli = lastSeenArchiveDateMilli {
                    returnValue["lastSeenArchiveDateMilli"] = lastSeenArchiveDateMilli
                }
                if let lastSeenArchiveId = lastSeenArchiveId {
                    returnValue["lastSeenArchiveId"] = lastSeenArchiveId
                }
                return returnValue
            }()
            return .requestParameters(parameters: param, encoding: URLEncoding.queryString)
        case .like:
            return .requestPlain
        case .unlike:
            return .requestPlain
        }
    }
    
    var validationType: ValidationType {
        return .successAndRedirectCodes
    }
    
    var headers: [String: String]? {
        switch self {
        case .isDuplicatedEmail:
            return nil
        case .loginEmail:
            return nil
        case .logInWithOAuth:
            return nil
        case .registArchive:
            return ["Authorization": LogInManager.shared.getLogInToken()]
        case .registEmail:
            return nil
        case .uploadImage:
            return nil
        case .deleteArchive:
            return ["Authorization": LogInManager.shared.getLogInToken()]
        case .getArchives:
            return ["Authorization": LogInManager.shared.getLogInToken()]
        case .getDetailArchive:
            return ["Authorization": LogInManager.shared.getLogInToken()]
        case .getCurrentUserInfo:
            return ["Authorization": LogInManager.shared.getLogInToken()]
        case .withdrawal:
            return ["Authorization": LogInManager.shared.getLogInToken()]
        case .getKakaoUserInfo(let kakaoAccessToken):
            return ["Authorization": "Bearer \(kakaoAccessToken)"]
        case .sendTempPassword:
            return nil
        case .changePassword:
            return nil
        case .getPublicArchives:
            return ["Authorization": LogInManager.shared.getLogInToken()]
        case .like:
            return ["Authorization": LogInManager.shared.getLogInToken()]
        case .unlike:
            return ["Authorization": LogInManager.shared.getLogInToken()]
        }
    }
    
}



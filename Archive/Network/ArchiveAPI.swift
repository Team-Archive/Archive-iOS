//
//  ArchiveAPI.swift
//  Archive
//
//  Created by hanwe on 2021/11/22.
//

import Moya

enum ArchiveAPI {
    case uploadImage(_ imageData: Data)
    case registArchive(_ info: RecordData)
    case registEmail(email: String, nickname: String, password: String)
    case registOAuth(nickname: String, provider: String, providerAccessToken: String)
    case loginEmail(_ param: LoginEmailParam)
    case logInWithOAuth(logInType: OAuthSignInType, token: String)
    case isDuplicatedEmail(_ eMail: String)
    case deleteArchive(archiveId: String)
    case getArchives(sortBy: String, emotion: String?, lastSeenArchiveDateMilli: Int?, lastSeenArchiveId: Int?)
    case getDetailArchive(archiveId: String)
    case getCurrentUserInfo
    case withdrawal
    case getKakaoUserInfo(kakaoAccessToken: String)
    case sendTempPassword(email: String)
    case changePassword(eMail: String, beforePassword: String, newPassword: String)
    case getPublicArchives(sortBy: String, emotion: String?, lastSeenArchiveDateMilli: Int?, lastSeenArchiveId: Int?)
    case like(archiveIdList: [String])
    case unlike(archiveIdList: [String])
    case getMyLikeList
    case getBanner
    case getThisMonthRegistArchiveCnt
    case report(archiveId: Int, reason: String)
    case uploadProfilePhotoImage(_ imageData: Data)
    case getIsDuplicatedNickname(_ nickname: String)
    case updateNickname(_ nickname: String)
    case getProfileInfo
}
        
extension ArchiveAPI: TargetType {
    
    var baseURL: URL {
        let domain: String = {
            var returnValue: String = ""
            switch ArchiveStatus.shared.mode {
            case .debug(let url):
                if let url = url {
                    returnValue = url
                } else {
                    returnValue = CommonDefine.devApiServer
                }
            case .normal:
                returnValue = CommonDefine.apiServer
            }
            return returnValue
        }()
        
        switch self {
        case .uploadImage, .registArchive, .registEmail, .loginEmail, .logInWithOAuth, .isDuplicatedEmail, .deleteArchive, .getArchives, .getDetailArchive, .getCurrentUserInfo, .withdrawal, .sendTempPassword, .changePassword, .getPublicArchives, .like, .unlike, .getBanner, .getThisMonthRegistArchiveCnt, .getMyLikeList, .report, .uploadProfilePhotoImage, .getIsDuplicatedNickname, .updateNickname, .getProfileInfo, .registOAuth:
            return URL(string: domain)!
        case .getKakaoUserInfo:
            return URL(string: CommonDefine.kakaoAPIServer)!
        }
    }
    
    var path: String {
        switch self {
        case .uploadImage:
            return "/api/v2/archive/image/upload"
        case .registArchive:
            return "/api/v1/archive"
        case .registEmail:
            return "/api/v2/auth/register"
        case .registOAuth:
            return "/api/v2/auth/register/social"
        case .loginEmail:
            return "/api/v1/auth/login"
        case .logInWithOAuth:
            return "/api/v2/auth/login/social"
        case .isDuplicatedEmail:
            return "/api/v2/user/duplicate/email"
        case .deleteArchive(let archiveId):
            return "/api/v1/archive/" + archiveId
        case .getArchives:
            return "/api/v2/archive"
        case .getDetailArchive(let archiveId):
            return "/api/v2/archive/" + archiveId
        case .getCurrentUserInfo:
            return "/api/v1/auth/info"
        case .withdrawal:
            return "/api/v1/auth/unregister"
        case .getKakaoUserInfo:
            return "/v2/user/me"
        case .sendTempPassword:
            return "api/v1/auth/password/temporary"
        case .changePassword:
            return "api/v2/auth/password/reset"
        case .getPublicArchives:
            return "/api/v2/archive/community"
        case .like:
            return "/api/v2/archive/like"
        case .unlike:
            return "/api/v2/archive/like"
        case .getMyLikeList:
            return "/api/v2/archive/like"
        case .getBanner:
            return "/api/v2/banner"
        case .getThisMonthRegistArchiveCnt:
            return "/api/v2/archive/count/month"
        case .report(let archiveId, _):
            return "/api/v2/report/\(archiveId)"
        case .uploadProfilePhotoImage:
            return "/api/v2/user/profile/image/upload"
        case .getIsDuplicatedNickname:
            return "/api/v2/user/duplicate/nickname"
        case .updateNickname:
            return "/api/v2/user/nickname"
        case .getProfileInfo:
            return "/api/v2/user/profile"
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
        case .getMyLikeList:
            return .get
        case .getBanner:
            return .get
        case .getThisMonthRegistArchiveCnt:
            return .get
        case .report:
            return .post
        case .uploadProfilePhotoImage:
            return .post
        case .getIsDuplicatedNickname:
            return .get
        case .updateNickname:
            return .put
        case .getProfileInfo:
            return .get
        case .registOAuth:
            return .post
        }
    }
    
    var task: Task {
        switch self {
        case .uploadImage(let imageData):
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd-HH:mm:ss"
            let data: MultipartFormData = MultipartFormData(provider: .data(imageData), name: "image", fileName: "\(dateFormatter.string(from: Date())).jpeg", mimeType: "image/jpeg")
            return .uploadMultipart([data])
        case .registArchive(let infoData):
            return .requestJSONEncodable(infoData)
        case .registEmail(let email, let nickname, let password):
            return .requestParameters(parameters: ["email": email, "nickname": nickname, "password": password], encoding: JSONEncoding.default)
        case .registOAuth(let nickname, let provider, let providerAccessToken):
            return .requestParameters(parameters: ["nickname": nickname, "provider": provider, "providerAccessToken": providerAccessToken], encoding: JSONEncoding.default)
        case .loginEmail(let param):
            return .requestJSONEncodable(param)
        case .logInWithOAuth(let type, let token):
            return .requestParameters(parameters: ["providerAccessToken": token, "provider": type.rawValue], encoding: JSONEncoding.default)
        case .isDuplicatedEmail(let email):
            return .requestParameters(parameters: ["value": email], encoding: URLEncoding.default)
        case .deleteArchive:
            return .requestPlain
        case .getArchives(let sortBy, let emotion, let lastSeenArchiveDateMilli, let lastSeenArchiveId):
            let param: [String: Any] = {
                var returnValue: [String: Any] = [String: Any]()
                returnValue["sortType"] = sortBy
                if let emotion = emotion {
                    returnValue["emotion"] = emotion
                }
                if let lastSeenArchiveDateMilli = lastSeenArchiveDateMilli, let lastSeenArchiveId = lastSeenArchiveId {
                    returnValue["lastArchiveDateTime"] = lastSeenArchiveDateMilli
                    returnValue["lastArchiveId"] = lastSeenArchiveId
                }
                return returnValue
            }()
            return .requestParameters(parameters: param, encoding: URLEncoding.queryString)
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
                if let lastSeenArchiveDateMilli = lastSeenArchiveDateMilli, let lastSeenArchiveId = lastSeenArchiveId {
                    returnValue["lastArchiveDateTime"] = lastSeenArchiveDateMilli
                    returnValue["lastArchiveId"] = lastSeenArchiveId
                }
                return returnValue
            }()
            return .requestParameters(parameters: param, encoding: URLEncoding.queryString)
        case .like(let list):
            return .requestParameters(parameters: ["archiveIds": list], encoding: JSONEncoding.default)
        case .unlike(let list):
            return .requestParameters(parameters: ["archiveIds": list], encoding: JSONEncoding.default)
        case .getMyLikeList:
            return .requestPlain
        case .getBanner:
            return .requestPlain
        case .getThisMonthRegistArchiveCnt:
            return .requestPlain
        case .report(_, let reason):
            return .requestParameters(parameters: ["reason": reason], encoding: JSONEncoding.default)
        case .uploadProfilePhotoImage(let imageData):
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd-HH:mm:ss"
            let data: MultipartFormData = MultipartFormData(provider: .data(imageData), name: "image", fileName: "\(dateFormatter.string(from: Date())).jpeg", mimeType: "image/jpeg")
            return .uploadMultipart([data])
        case .getIsDuplicatedNickname(let nickName):
            return .requestParameters(parameters: ["value": nickName], encoding: URLEncoding.queryString)
        case .updateNickname(let newNickname):
            return .requestParameters(parameters: ["nickname": newNickname], encoding: JSONEncoding.default)
        case .getProfileInfo:
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
            return ["Authorization": LogInManager.shared.accessToken]
        case .registEmail:
            return nil
        case .registOAuth:
            return nil
        case .uploadImage:
            return ["Authorization": LogInManager.shared.accessToken]
        case .deleteArchive:
            return ["Authorization": LogInManager.shared.accessToken]
        case .getArchives:
            return ["Authorization": LogInManager.shared.accessToken]
        case .getDetailArchive:
            return ["Authorization": LogInManager.shared.accessToken]
        case .getCurrentUserInfo:
            return ["Authorization": LogInManager.shared.accessToken]
        case .withdrawal:
            return ["Authorization": LogInManager.shared.accessToken]
        case .getKakaoUserInfo(let kakaoAccessToken):
            return ["Authorization": "Bearer \(kakaoAccessToken)"]
        case .sendTempPassword:
            return nil
        case .changePassword:
            return ["Authorization": LogInManager.shared.accessToken]
        case .getPublicArchives:
            return ["Authorization": LogInManager.shared.accessToken]
        case .like:
            return ["Authorization": LogInManager.shared.accessToken]
        case .unlike:
            return ["Authorization": LogInManager.shared.accessToken]
        case .getMyLikeList:
            return ["Authorization": LogInManager.shared.accessToken]
        case .getBanner:
            return ["Authorization": LogInManager.shared.accessToken]
        case .getThisMonthRegistArchiveCnt:
            return ["Authorization": LogInManager.shared.accessToken]
        case .report:
            return ["Authorization": LogInManager.shared.accessToken]
        case .uploadProfilePhotoImage:
            return ["Authorization": LogInManager.shared.accessToken]
        case .getIsDuplicatedNickname:
            return nil
        case .updateNickname:
            return ["Authorization": LogInManager.shared.accessToken]
        case .getProfileInfo:
            return ["Authorization": LogInManager.shared.accessToken]
        }
    }
    
}



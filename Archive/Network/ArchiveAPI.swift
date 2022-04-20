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
    case loginWithKakao(kakaoAccessToken: String)
    case isDuplicatedEmail(_ eMail: String)
    case deleteArchive(archiveId: String)
    case getArchives
    case getDetailArchive(archiveId: String)
    case getCurrentUserInfo
    case withdrawal
    case getKakaoUserInfo(kakaoAccessToken: String)
    case sendTempPassword(email: String)
    case changePassword(eMail: String, beforePassword: String, newPassword: String)
}
extension ArchiveAPI: TargetType {
    
    var baseURL: URL {
        switch self {
        case .uploadImage:
            return URL(string: CommonDefine.apiServer)!
        case .registArchive:
            return URL(string: CommonDefine.apiServer)!
        case .registEmail:
            return URL(string: CommonDefine.apiServer)!
        case .loginEmail:
            return URL(string: CommonDefine.apiServer)!
        case .loginWithKakao:
            return URL(string: CommonDefine.apiServer)!
        case .isDuplicatedEmail:
            return URL(string: CommonDefine.apiServer)!
        case .deleteArchive:
            return URL(string: CommonDefine.apiServer)!
        case .getArchives:
            return URL(string: CommonDefine.apiServer)!
        case .getDetailArchive:
            return URL(string: CommonDefine.apiServer)!
        case .getCurrentUserInfo:
            return URL(string: CommonDefine.apiServer)!
        case .withdrawal:
            return URL(string: CommonDefine.apiServer)!
        case .getKakaoUserInfo:
            return URL(string: CommonDefine.kakaoAPIServer)!
        case .sendTempPassword:
            return URL(string: CommonDefine.apiServer)!
        case .changePassword:
            return URL(string: CommonDefine.apiServer)!
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
        case .loginWithKakao:
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
        case .loginWithKakao:
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
        case .loginWithKakao(let kakaoAccessToken):
            return .requestParameters(parameters: ["providerAccessToken": kakaoAccessToken, "provider": "kakao"], encoding: JSONEncoding.default)
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
        case .loginWithKakao:
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
//            return ["Authorization": "Bearer " + LogInManager.shared.getLogInToken()]
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
        }
    }
    
}



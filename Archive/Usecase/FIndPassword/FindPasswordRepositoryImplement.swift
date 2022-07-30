//
//  FindPasswordRepositoryImplement.swift
//  Archive
//
//  Created by hanwe on 2022/04/16.
//

import RxSwift
import Moya
import SwiftyJSON

class FindPasswordRepositoryImplement: FindPasswordRepository {
    func isExistEmail(email: String) -> Observable<Result<Bool, ArchiveError>> {
        let provider = ArchiveProvider.shared.provider
        return provider.rx.request(.isDuplicatedEmail(email), callbackQueue: DispatchQueue.global())
            .asObservable()
            .map { result in
                if result.statusCode == 200 {
                    guard let resultJson: JSON = try? JSON.init(data: result.data) else { return .failure(.init(.invaldData))}
                    if resultJson["duplicatedEmail"].boolValue {
                        return .success(true)
                    } else {
                        return .success(false)
                    }
                } else {
                    return .failure(.init(from: .server, code: result.statusCode, message: "서버오류"))
                }
            }
            .catch { err in
                    .just(.failure(.init(from: .server, code: err.responseCode, message: err.archiveErrMsg)))
            }
    }
    
    func sendTempPassword(email: String) -> Observable<Result<Void, ArchiveError>> {
        let provider = ArchiveProvider.shared.provider
        return provider.rx.request(.sendTempPassword(email: email), callbackQueue: DispatchQueue.global())
            .asObservable()
            .map { result in
                if result.statusCode == 200 {
                    return .success(())
                } else {
                    return .failure(.init(from: .server, code: result.statusCode, message: "서버오류"))
                }
            }
            .catch { err in
                    .just(.failure(.init(from: .server, code: err.responseCode, message: err.archiveErrMsg)))
            }
    }
    
    func changePassword(eMail: String, currentPassword: String, newPassword: String) -> Observable<Result<Void, ArchiveError>> {
        let provider = ArchiveProvider.shared.provider
        return provider.rx.request(.changePassword(eMail: eMail, beforePassword: currentPassword, newPassword: newPassword), callbackQueue: DispatchQueue.global())
            .asObservable()
            .map { result in
                if result.statusCode == 200 {
                    return .success(())
                } else {
                    return .failure(.init(from: .server, code: result.statusCode, message: "서버오류"))
                }
            }
            .catch { err in
                    .just(.failure(.init(from: .server, code: err.responseCode, message: err.archiveErrMsg)))
            }
    }
    
    func withdrawal() -> Observable<Result<Void, ArchiveError>> {
        let provider = ArchiveProvider.shared.provider
        
        return provider.rx.request(.withdrawal, callbackQueue: DispatchQueue.global())
            .asObservable()
            .map { result in
                if result.statusCode == 200 {
                    return .success(())
                } else {
                    return .failure(.init(from: .server, code: result.statusCode, message: ""))
                }
            }
            .catch { err in
                return .just(.failure(.init(from: .server, code: err.responseCode, message: err.archiveErrMsg)))
            }
    }
}

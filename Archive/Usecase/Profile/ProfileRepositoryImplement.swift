//
//  UpdateProfileRepositoryImplement.swift
//  Archive
//
//  Created by hanwe on 2022/09/24.
//

import RxSwift
import SwiftyJSON

class ProfileRepositoryImplement: ProfileRepository {
    
    // MARK: private function
    
    // MARK: internal function
    
    func updateNickname(_ newNickname: String) -> Observable<Result<Void, ArchiveError>> {
        let provider = ArchiveProvider.shared.provider
        return provider.rx.request(.updateNickname(newNickname), callbackQueue: DispatchQueue.global())
            .asObservable()
            .map { result in
                if 200...299 ~= result.statusCode {
                    return .success(())
                } else {
                    return .failure(.init(from: .server, code: result.statusCode, message: "서버오류"))
                }
            }
            .catch { err in
                return .just(.failure(.init(from: .server, code: err.responseCode, message: err.archiveErrMsg)))
            }
    }
    
    func getProfile() -> Observable<Result<ProfileData, ArchiveError>> {
        let provider = ArchiveProvider.shared.provider
        return provider.rx.request(.getProfileInfo, callbackQueue: DispatchQueue.global())
            .asObservable()
            .map { result in
                if 200...299 ~= result.statusCode {
                    if result.statusCode == 200 {
                        guard let profile = ProfileData.fromJson(jsonData: result.data) else { return .failure(.init(.deserializationFail))}
                        return .success(profile)
                    } else {
                        return .failure(.init(from: .server, code: result.statusCode, message: "서버오류"))
                    }
                } else {
                    return .failure(.init(from: .server, code: result.statusCode, message: "서버오류"))
                }
            }
            .catch { err in
                return .just(.failure(.init(from: .server, code: err.responseCode, message: err.archiveErrMsg)))
            }
    }
    
}

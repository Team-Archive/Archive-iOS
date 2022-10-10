//
//  ArchiveError.swift
//  Archive
//
//  Created by hanwe on 2022/03/20.
//


import UIKit

enum ArchiveErrorCode: Int, LocalizedError, Equatable {
    case commonError = 10000
    case dataToJsonFail
    case stringToDataFail
    case invaldData // 데이터가 유효하지 않음
    case publicArchiveIsRefreshed // 데이터가 초기화된듯
    case publicArchiveIsEndOfPage // 페이지의 끝임
    case photoAuth // 사진접근권한이 없음
    case selfIsNull // self == null
    
    case archiveOAuthError = 11000
    case unexpectedAppleSignIn = 11100 // 에러는 발생하지 않았지만 애플로그인 이상함
    case tokenNotExsitAppleSignIn // 애플로그인 토큰 없음
    case tokenAsciiToStringFailAppleSignIn // 애플로그인 토큰데이터 -> 스트링 변환 실패
    case invalidLoginType // 로그인 타입이 유효하지않음
    case unexpectedKakaoSignIn = 11120
    case kakaoIsNotIntalled // 카카오톡이 설치되어있지 않음
    case kakaoIdTokenIsNull // 카카오 ID Token이 존재하지 않음
    case responseHeaderIsNull // 헤더 존재하지 않음
    case loginTokenIsNull // 로그인 토큰이 존재하지않음
    
    case imageUploadCntFail // 이미지가 다 업로드 되지 않은듯
    case imageUploadFail // 이미지 Url이 없음
    case archiveDataIsInvaild // 아카이브 등록 데이터 이상함.. 버그인듯
    case editProfileIsInvaild // 프로필 업데이트 데이터 이상함
    case convertImageFail // 이미지 변환 실패
}

enum ErrorFrom {
    case own
    case server
    case network
    case appleOAuth
    case kakaoOAuth
}

class ArchiveError: Error {
    // MARK: private property
    
    private let from: ErrorFrom
    private let message: String
    
    // MARK: property
    
    let code: Int
    let archiveErrorCode: ArchiveErrorCode?
    
    // MARK: lifeCycle
    
    init(from: ErrorFrom, code: Int, message: String, errorCode: ArchiveErrorCode? = nil) {
        self.from = from
        self.code = code
        self.message = message
        self.archiveErrorCode = errorCode
    }
    
    convenience init(_ errorCode: ArchiveErrorCode) {
        self.init(from: .own, code: errorCode.rawValue, message: ArchiveError.getMessageFromArchiveErrorCode(errorCode), errorCode: errorCode)
    }

    convenience init(from: ErrorFrom, code: Int, message: String) {
        self.init(from: from, code: code, message: message, errorCode: nil)
    }
    
    // MARK: private func
    
    private static func getMessageFromArchiveErrorCode(_ code: ArchiveErrorCode) -> String {
        var returnValue: String = ""
        switch code {
        case .commonError:
            returnValue = "오류"
        case .dataToJsonFail:
            returnValue = "데이터 직렬화 실패"
        case .stringToDataFail:
            returnValue = "데이터 생성 실패"
        case .invaldData:
            returnValue = "유효하지 않은 데이터"
        case .archiveOAuthError:
            returnValue = "소셜 로그인 오류"
        case .unexpectedAppleSignIn:
            returnValue = "애플 로그인 오류"
        case .tokenNotExsitAppleSignIn:
            returnValue = "애플 로그인 오류, 토큰이 존재하지 않음"
        case .tokenAsciiToStringFailAppleSignIn:
            returnValue = "애플로그인 오류, 아스키 변환 실패"
        case .unexpectedKakaoSignIn:
            returnValue = "카카오 로그인 오류"
        case .kakaoIsNotIntalled:
            returnValue = "카카오톡이 설치되어있지 않습니다."
        case .kakaoIdTokenIsNull:
            returnValue = "카카오 로그인 오류"
        case .responseHeaderIsNull:
            returnValue = "로그인 응답 오류"
        case .loginTokenIsNull:
            returnValue = "로그인 토큰 오류"
        case .publicArchiveIsRefreshed:
            returnValue = "데이터 오류"
        case .publicArchiveIsEndOfPage:
            returnValue = "더 이상 공개된 카드가 없어요 😭"
        case .photoAuth:
            returnValue = "티켓 기록 사진을 선택하려면 사진 라이브러리 접근권한이 필요합니다."
        case .imageUploadCntFail:
            returnValue = "이미지 업로드 오류"
        case .imageUploadFail:
            returnValue = "이미지 업로드 오류"
        case .selfIsNull:
            returnValue = "오류"
        case .archiveDataIsInvaild:
            returnValue = "오류"
        case .editProfileIsInvaild:
            returnValue = "오류"
        case .convertImageFail:
            returnValue = "이미지 변환 오류"
        case .invalidLoginType:
            returnValue = "유효하지 않은 로그인 타입"
        }
        return returnValue
    }
    
    // MARK: func
    
    func getMessage() -> String {
        return "[\(self.code)]\n\(self.message)"
    }
    
}

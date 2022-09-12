//
//  ReportReason.swift
//  Archive
//
//  Created by hanwe on 2022/09/06.
//

import Foundation

enum ReportReason: CaseIterable {
    case spam
    case sexual
    case fraud
    case hatred
    case harassment
    case violence
    case copyright
    case illegalGoods
    case suicide
    
    var localizaedValue: String {
        switch self {
        case .spam:
            return "스팸"
        case .sexual:
            return "나체 이미지 또는 성적 행위"
        case .fraud:
            return "사기 또는 거짓"
        case .hatred:
            return "혐오 발언 또는 상징"
        case .harassment:
            return "따돌림 또는 괴롭힙"
        case .violence:
            return "폭력 또는 위험한 단체"
        case .copyright:
            return "지적 재산권 침해"
        case .illegalGoods:
            return "불법 또는 규제 상품 판매"
        case .suicide:
            return "자살 또는 자해"
        }
    }
    
    static func getItemAtIndex(_ index: Int) -> ReportReason {
        return ReportReason.allCases[index]
    }
}

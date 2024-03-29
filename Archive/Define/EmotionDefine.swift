//
//  EmotionDefine.swift
//  Archive
//
//  Created by hanwe lee on 2021/10/25.
//

import UIKit

@objc enum Emotion: Int, CaseIterable, Codable {
    case pleasant = 0
    case fun
    case splendid
    case impressive
    case wonderful
    case interesting
    case fresh
    case touching
    case shame

    enum CodingKeys: String, CodingKey {
        case pleasant = "PLEASANT"
        case fun = "INTERESTING"
        case splendid = "BEAUTIFUL"
        case impressive = "IMPRESSIVE"
        case wonderful = "AMAZING"
        case interesting = "INTERESTING2"
        case fresh = "FRESH"
        case touching = "TOUCHING"
        case shame = "SHAME"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .fun:
            try container.encode(Emotion.fun, forKey: .fun)
        case .pleasant:
            try container.encode(Emotion.pleasant, forKey: .pleasant)
        case .splendid:
            try container.encode(Emotion.splendid, forKey: .splendid)
        case .impressive:
            try container.encode(Emotion.impressive, forKey: .impressive)
        case .wonderful:
            try container.encode(Emotion.wonderful, forKey: .wonderful)
        case .interesting:
            try container.encode(Emotion.interesting, forKey: .interesting)
        case .fresh:
            try container.encode(Emotion.fresh, forKey: .fresh)
        case .touching:
            try container.encode(Emotion.touching, forKey: .touching)
        case .shame:
            try container.encode(Emotion.shame, forKey: .shame)
        }
    }
    
    init(from decoder: Decoder) throws {
        if let rawValue = try? decoder.singleValueContainer().decode(String.self) {
            self.init(rawValue: Emotion.fromString(rawValue)?.rawValue ?? 0)!
        } else {
            self.init(rawValue: 0)!
        }
    }
    
    static func fromString(_ str: String) -> Emotion? {
        for item in Emotion.allCases where item.rawStringValue == str {
            return item
        }
        return nil
    }
    
    var rawStringValue: String {
        switch self {
        case .fun:
            return "INTERESTING"
        case .impressive:
            return "IMPRESSIVE"
        case .pleasant:
            return "PLEASANT"
        case .splendid:
            return "BEAUTIFUL"
        case .wonderful:
            return "AMAZING"
        case .interesting:
            return "INTERESTING2"
        case .fresh:
            return "FRESH"
        case .touching:
            return "TOUCHING"
        case .shame:
            return "SHAME"
        }
    }
    
    var toOrderIndex: Int {
        var currentEmotionIndex: Int = 0
        for item in Emotion.allCases {
            if item == self {
                return currentEmotionIndex
            }
            currentEmotionIndex += 1
        }
        return 0
    }
    
    static func getEmotionFromIndex(_ index: Int) -> Emotion? {
        if index + 1 > Emotion.allCases.count { return nil }
        var currentEmotionIndex: Int = 0
        for item in Emotion.allCases {
            if currentEmotionIndex == index {
                return item
            }
            currentEmotionIndex += 1
        }
        return nil
    }
    
    var localizationTitle: String {
        switch self {
        case .fun:
            return "재미있는"
        case .impressive:
            return "인상적인"
        case .pleasant:
            return "기분좋은"
        case .splendid:
            return "아름다운"
        case .wonderful:
            return "경이로운"
        case .interesting:
            return "흥미로운"
        case .fresh:
            return "신선한"
        case .touching:
            return "감동적인"
        case .shame:
            return "아쉬운"
        }
    }
    
    var coverImage: UIImage {
        switch self {
        case .fun:
            return Gen.Images.coverFun.image
        case .impressive:
            return Gen.Images.coverImpressive.image
        case .pleasant:
            return Gen.Images.coverPleasant.image
        case .splendid:
            return Gen.Images.coverSplendid.image
        case .wonderful:
            return Gen.Images.coverWonderful.image
        case .interesting:
            return Gen.Images.coverInteresting.image
        case .fresh:
            return Gen.Images.coverFresh.image
        case .touching:
            return Gen.Images.coverTouching.image
        case .shame:
            return Gen.Images.coverShame.image
        }
    }
    
    var coverAlphaImage: UIImage {
        switch self {
        case .fun:
            return Gen.Images.colorFun.image
        case .impressive:
            return Gen.Images.colorImpressive.image
        case .pleasant:
            return Gen.Images.colorPleasant.image
        case .splendid:
            return Gen.Images.colorSplendid.image
        case .wonderful:
            return Gen.Images.colorWonderful.image
        case .interesting:
            return Gen.Images.colorInteresting.image
        case .fresh:
            return Gen.Images.colorFresh.image
        case .touching:
            return Gen.Images.colorTouching.image
        case .shame:
            return Gen.Images.colorShame.image
        }
    }
    
    var color: UIColor {
        switch self {
        case .fun:
            return Gen.Colors.funYellow.color
        case .impressive:
            return Gen.Colors.impressiveGreen.color
        case .pleasant:
            return Gen.Colors.pleasantRed.color
        case .splendid:
            return Gen.Colors.splendidBlue.color
        case .wonderful:
            return Gen.Colors.wonderfulPurple.color
        case .interesting:
            return Gen.Colors.interestingPink.color
        case .fresh:
            return Gen.Colors.freshMint.color
        case .touching:
            return Gen.Colors.touchingOrange.color
        case .shame:
            return Gen.Colors.shameNavy.color
        }
    }
    
    var darkenColor: UIColor {
        switch self {
        case .fun:
            return Gen.Colors.funYellowDarken.color
        case .impressive:
            return Gen.Colors.impressiveGreenDarken.color
        case .pleasant:
            return Gen.Colors.pleasantRedDarken.color
        case .splendid:
            return Gen.Colors.splendidBlueDarken.color
        case .wonderful:
            return Gen.Colors.wonderfulPurpleDarken.color
        case .interesting:
            return Gen.Colors.interestingPinkDarken.color
        case .fresh:
            return Gen.Colors.freshMintDarken.color
        case .touching:
            return Gen.Colors.touchingOrangeDarken.color
        case .shame:
            return Gen.Colors.shameNavyDarken.color
        }
    }
    
    var miniImage: UIImage {
        switch self {
        case .fun:
            return Gen.Images.typeFunMini.image
        case .impressive:
            return Gen.Images.typeImpressiveMini.image
        case .pleasant:
            return Gen.Images.typePleasantMini.image
        case .splendid:
            return Gen.Images.typeSplendidMini.image
        case .wonderful:
            return Gen.Images.typeWonderfulMini.image
        case .interesting:
            return Gen.Images.typeInterestingMini.image
        case .fresh:
            return Gen.Images.typeFreshMini.image
        case .touching:
            return Gen.Images.typeTouchingMini.image
        case .shame:
            return Gen.Images.typeShameMini.image
        }
    }
    
    var typeImage: UIImage {
        switch self {
        case .fun:
            return Gen.Images.typeFun.image
        case .impressive:
            return Gen.Images.typeImpressive.image
        case .pleasant:
            return Gen.Images.typePleasant.image
        case .splendid:
            return Gen.Images.typeSplendid.image
        case .wonderful:
            return Gen.Images.typeWonderful.image
        case .interesting:
            return Gen.Images.typeInteresting.image
        case .fresh:
            return Gen.Images.typeFresh.image
        case .touching:
            return Gen.Images.typeTouching.image
        case .shame:
            return Gen.Images.typeShame.image
        }
    }
    
    var typeNoImage: UIImage {
        switch self {
        case .fun:
            return Gen.Images.typeFunNo.image
        case .impressive:
            return Gen.Images.typeImpressiveNo.image
        case .pleasant:
            return Gen.Images.typePleasantNo.image
        case .splendid:
            return Gen.Images.typeSplendidNo.image
        case .wonderful:
            return Gen.Images.typeWonderfulNo.image
        case .interesting:
            return Gen.Images.typeInterestingNo.image
        case .fresh:
            return Gen.Images.typeFreshNo.image
        case .touching:
            return Gen.Images.typeTouchingNo.image
        case .shame:
            return Gen.Images.typeShameNo.image
        }
    }
    
    var preImage: UIImage {
        switch self {
        case .fun:
            return Gen.Images.preFun.image
        case .impressive:
            return Gen.Images.preImpressive.image
        case .pleasant:
            return Gen.Images.prePleasant.image
        case .splendid:
            return Gen.Images.preSplendid.image
        case .wonderful:
            return Gen.Images.preWonderful.image
        case .interesting:
            return Gen.Images.preInteresting.image
        case .fresh:
            return Gen.Images.preFresh.image
        case .touching:
            return Gen.Images.preTouching.image
        case .shame:
            return Gen.Images.preShame.image
        }
    }
    
    var dimImage: UIImage {
        switch self {
        case .fun:
            return Gen.Images.dimFun.image
        case .impressive:
            return Gen.Images.dimImpressive.image
        case .pleasant:
            return Gen.Images.dimPleasant.image
        case .splendid:
            return Gen.Images.dimSplendid.image
        case .wonderful:
            return Gen.Images.dimWonderful.image
        case .interesting:
            return Gen.Images.dimInteresting.image
        case .fresh:
            return Gen.Images.dimFresh.image
        case .touching:
            return Gen.Images.dimTouching.image
        case .shame:
            return Gen.Images.dimShame.image
        }
    }
    
    var filterImage: UIImage {
        switch self {
        case .fun:
            return Gen.Images.filterFun.image
        case .impressive:
            return Gen.Images.filterImpressive.image
        case .pleasant:
            return Gen.Images.filterPleasant.image
        case .splendid:
            return Gen.Images.filterSplendid.image
        case .wonderful:
            return Gen.Images.filterWonderful.image
        case .interesting:
            return Gen.Images.filterInteresting.image
        case .fresh:
            return Gen.Images.filterFresh.image
        case .touching:
            return Gen.Images.filterTouching.image
        case .shame:
            return Gen.Images.filterShame.image
        }
    }
}

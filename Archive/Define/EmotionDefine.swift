//
//  EmotionDefine.swift
//  Archive
//
//  Created by hanwe lee on 2021/10/25.
//

enum Emotion: String, CaseIterable {
    case fun = "INTERESTING"
    case impressive = "IMPRESSIVE"
    case pleasant = "PLEASANT"
    case splendid = "BEAUTIFUL"
    case wonderful = "AMAZING"
//    case interesting = "INTERESTING2" // TODO: 서버에서 어떻게 내려올까..?
//    case fresh = "FRESH"
//    case touching = "TOUCHING"
    
    static func fromString(_ str: String) -> Emotion? {
        for item in Emotion.allCases where item.rawValue == str {
            return item
        }
        return nil
    }
}

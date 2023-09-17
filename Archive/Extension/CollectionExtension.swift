//
//  CollectionExtension.swift
//  Archive
//
//  Created by hanwe on 2023/09/02.
//

import Foundation

extension Collection {
    public subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}


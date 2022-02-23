//
//  PointEntry.swift
//  Interface
//
//  Created by Eugene Dudkin on 23.02.2022.
//

import Foundation

struct PointEntry {
    let value: Int
    let label: String
}

extension PointEntry: Comparable {
    static func < (lhs: PointEntry, rhs: PointEntry) -> Bool {
        return lhs.value < rhs.value
    }
    static func == (lhs: PointEntry, rhs: PointEntry) -> Bool {
        return lhs.value == rhs.value
    }
}

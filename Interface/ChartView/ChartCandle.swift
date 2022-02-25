//
//  PointEntry.swift
//  Interface
//
//  Created by Eugene Dudkin on 23.02.2022.
//

import Foundation

struct ChartCandle {
    let value: Int
    let label: String
}

extension ChartCandle: Comparable {
    static func < (lhs: ChartCandle, rhs: ChartCandle) -> Bool {
        return lhs.value < rhs.value
    }
    static func == (lhs: ChartCandle, rhs: ChartCandle) -> Bool {
        return lhs.value == rhs.value
    }
}

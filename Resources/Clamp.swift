//
//  Clamp.swift
//  Verifiedly
//
//  Created by Samuel Ailemen on 6/21/21.
//

import Foundation

extension Comparable {
    func clamped(lowerBound: Self, upperBound: Self) -> Self {
        return min(max(self, lowerBound), upperBound)
    }
}

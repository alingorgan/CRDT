//
//  Pair.swift
//  CRDT
//
//  Created by Alin-Manuel GORGAN on 13/03/2021.
//

import Foundation

public struct Pair<T, U> {
    public let first: T
    public let second: U
    
    public init(_ first: T, _ second: U) {
        self.first = first
        self.second = second
    }
}

extension Pair: Hashable, Equatable where T: Hashable, U: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(first)
        hasher.combine(second)
    }
}

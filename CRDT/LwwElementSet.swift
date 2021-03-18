//
//  LwwElementSet.swift
//  CRDT
//
//  Created by Alin-Manuel GORGAN on 13/03/2021.
//

import Foundation

/**
 Defines a **L**ast **W**rite **W**ins element set.
 LWW-Element-Set is similar to 2P-Set in that it consists of an "add set" and a "remove set", with a timestamp for each element.
 */
public struct LwwElementSet<Element: Hashable> {
    
    /// Defines a log entry for a change (mutating) operation.
    struct Change: Comparable {
        /// Defines the time at which the change has occured.
        let timestamp = NSDate.timeIntervalSinceReferenceDate
        
        /// Establishes the order of two change events.
        /// - parameters:
        ///     - change: The other change event.
        /// - returns: **True** if the current event precedes the given change event, **False** otherwise.
        func precedes(_ change: Self) -> Bool {
            self < change
        }
        
        static func < (lhs: Change, rhs: Change) -> Bool {
            lhs.timestamp < rhs.timestamp
        }
    }
    
    /// Defines an error which can occur as a result of an change (mutating) operation.
    public enum Failure: Error {
        case ElementDoesNotExist
    }
    
    /// Defines a collection of all added elements and the details of the addition.
    private var additions = [Element: Change]()
    
    /// Defines a collection of all removed elements and the details of the removal.
    private var removals = [Element: Change]()
    
    init(additions: [Element: Change],
         removals: [Element: Change]) {
        self.additions = additions
        self.removals = removals
    }
    
    public init() { }
}

extension LwwElementSet: Replicatable {
    
    public var all: Set<Element> {
        Set(additions.keys.filter(contains))
    }
    
    @discardableResult
    mutating public func add(_ element: Element) -> Result<Void, Error> {
        additions[element] = .init()
        return .success(Void())
    }
    
    @discardableResult
    mutating public func remove(_ element: Element) -> Result<Void, Error> {
        let elementDidExist = contains(element)
        removals[element] = .init()
        return elementDidExist ? .success(Void()) : .failure(Failure.ElementDoesNotExist)
    }
    
    public func contains(_ element: Element) -> Bool {
        guard let addition = additions[element] else { return false }
        guard let removal = removals[element] else { return true }
        return removal.precedes(addition)
    }
    
    public func merging(_ other: LwwElementSet<Element>) -> LwwElementSet<Element> {
        .init(
            additions: additions.merging(other.additions, uniquingKeysWith: max),
            removals: removals.merging(other.removals, uniquingKeysWith: max)
        )
    }
}

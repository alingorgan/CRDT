//
//  Replicatable.swift
//  CRDT
//
//  Created by Alin-Manuel GORGAN on 13/03/2021.
//

/**
    Defines a **C**onflict **F**ree **R**eplicating **D**ata **T**ype collection (CRDT)
 */
public protocol Replicatable: Equatable {
    
    /// The collection element type
    associatedtype Element: Hashable
    
    /// Returns all elements the collection contains
    var all: Set<Element> { get }
    
    /// Adds an element to the collection
    /// - parameters:
    ///     - element: The element to be added
    /// - returns: A result describing the success or failure of the operation.
    /// 
    @discardableResult
    mutating func add(_ element: Element) -> Result<Void, Error>
    
    
    /// Removes an element from the collection
    /// - parameters:
    ///     - element: The element to be removed
    /// - returns: A result describing the success or failure of the operation.
    ///
    @discardableResult
    mutating func remove(_ element: Element) -> Result<Void, Error>
    
    /// Checks if the collection contains an element
    /// - parameters:
    ///     - element: The element to looked up
    /// - returns: **True** if the element exists, **False** otherwise
    ///
    func contains(_ element: Element) -> Bool
    
    /// Merges this collection with another collection replica
    /// - parameters:
    ///     - other: The collection replica to be merged
    /// - returns: A new collection containg the merged items from both the current collection and the collection replica.
    ///
    func merging(_ other: Self) -> Self
}

extension Replicatable  {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.all == rhs.all
    }
}

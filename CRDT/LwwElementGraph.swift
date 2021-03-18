//
//  LwwElementGraph.swift
//  CRDT
//
//  Created by Alin-Manuel GORGAN on 13/03/2021.
//

import Foundation

/**
 ## Description
 Defines a **L**ast **W**rite **W**ins element graph.
 
 ## Discussion
 LWW-Element-Graph is similar to 2P-Set in that it consists of an "add set" and a "remove set", with a timestamp for each element.
 
 A graph is a pair of sets (V,E) (called vertices and edges respectively) such that E ⊆ V × V. Any of the Set implementations described above can be used for to V and E.
 */
public struct LwwElementGraph<T: Hashable>: Replicatable {
    
    public typealias Element = Entry<T>
    
    /// Defines the nodes added to the graph.
    var nodes = LwwElementSet<T>()
    
    /// Defines the nodes removed from the graph.
    var edges = LwwElementSet<Pair<T, T>>()
    
    public init() { }
    
    init(nodes: LwwElementSet<T>, edges: LwwElementSet<Pair<T, T>>) {
        self.nodes = nodes
        self.edges = edges
    }
    
    public var all: Set<Entry<T>> {
        Set(nodes.all.map(Entry.node) +
            edges.all.map { .edge($0.first, $0.second) })
    }
    
    @discardableResult
    mutating public func add(_ element: Entry<T>) -> Result<Void, Error> {
        switch element {
        case .node(let node):
            nodes.add(node)
        case .edge(let lhs, let rhs):
            guard nodes.contains(lhs) else {
                return .failure(Failure.DependentNotFound(.node(lhs)))
            }
            
            guard nodes.contains(rhs) else {
                return .failure(Failure.DependentNotFound(.node(rhs)))
            }
            
            edges.add(.init(lhs, rhs))
        }
        
        return .success(Void())
    }
    
    @discardableResult
    mutating public func remove(_ element: Entry<T>) -> Result<Void, Error> {
        switch element {
        case .node(let node):
            let edges = self.edges
            let edgeExists = { edges.contains(.init(node, $0)) }
            if let otherNode = nodes.all.first(where: edgeExists) {
                return .failure(Failure.DependentFound(.edge(node, otherNode)))
            }
            return nodes.remove(node)
        case .edge(let lhs, let rhs):            
            return edges.remove(.init(lhs, rhs))
        }
    }
    
    public func contains(_ element: Entry<T>) -> Bool {
        switch element {
        case .node(let value):
            return nodes.contains(value)
        case .edge(let lhs, let rhs):
            return edges.contains(.init(lhs, rhs))
        }
    }
    
    public func merging(_ other: LwwElementGraph<T>) -> LwwElementGraph<T> {
        .init(nodes: nodes.merging(other.nodes),
              edges: edges.merging(other.edges))
    }
}

extension LwwElementGraph  {
    
    /// Defines a kind of failure which occurs as a result of a change (mutating) operation.
    public enum Failure<T>: Error {
        
        /// Defines an error which occurs when the change (mutating) operation references an item which does not exist.
        case DependentNotFound(Entry<T>)
        
        /// Defines an error which occurs when the change (mutating) operation references an item which exists and depends on the item which is being removed.
        case DependentFound(Entry<T>)
    }
    
    /// Defines the kind of items the graph supports.
    public enum Entry<T> {
        case node(T)
        case edge(T, T)
    }
}

extension LwwElementGraph.Failure: Equatable where T: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.DependentNotFound(let lhsEntry), .DependentNotFound(let rhsEntry)):
            return lhsEntry == rhsEntry
        case (.DependentFound(let lhsEntry), .DependentFound(let rhsEntry)):
            return lhsEntry == rhsEntry
        default:
            return false
        }
    }
}

extension LwwElementGraph.Entry: Equatable where T: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.node(let lhsValue), .node(let rhsValue)):
            return lhsValue == rhsValue
        case (.edge(let lhsEdgelhsValue, let lhsEdgeRhsValue), .edge(let rhsEdgelhsValue, let rhsEdgeRhsValue)):
            return lhsEdgelhsValue == rhsEdgelhsValue && lhsEdgeRhsValue == rhsEdgeRhsValue
        default:
            return false
        }
    }
}

extension LwwElementGraph.Entry: Hashable where T: Hashable {
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .node(let node):
            hasher.combine(node)
        case .edge(let lhsNode, let rhsNode):
            hasher.combine(lhsNode)
            hasher.combine(rhsNode)
        }
    }
}

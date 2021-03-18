//
//  CRDT+Utils.swift
//  CRDT
//
//  Created by Alin-Manuel GORGAN on 13/03/2021.
//

import Foundation
@testable import CRDT

extension LwwElementGraph: CustomDebugStringConvertible {
    public var debugDescription: String {
        ["Nodes", nodes.debugDescription,
         "Edges:", edges.debugDescription].joined(separator: "\n")
    }
}

extension LwwElementSet: CustomDebugStringConvertible {
    public var debugDescription: String {
        all.map { String(describing: $0) }.joined(separator: " ")
    }
}

extension Pair: CustomDebugStringConvertible {
    public var debugDescription: String {
        "\(first) -> \(second)"
    }
}

extension LwwElementGraph.Failure: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .DependentFound(let entry), .DependentNotFound(let entry):
            return "Dependant \(entry.typeDescription) found \(entry.debugDescription)"
        }
    }
}

extension LwwElementGraph.Entry: CustomDebugStringConvertible {
    var typeDescription: String {
        switch self {
        case .node:
            return "node"
        case .edge:
            return "edge"
        }
    }
    
    public var debugDescription: String {
        switch self {
        case .node(let node):
            return String(describing: node)
        case .edge(let lhsNode, let rhsNode):
            return "(\(lhsNode),\(rhsNode))"
        }
    }
}

extension Result: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .success:
            return "Success"
        case .failure(let error):
            return "Error: \(error)"
        }
    }
}

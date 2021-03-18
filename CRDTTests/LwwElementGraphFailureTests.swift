//
//  LwwElementGraph.swift
//  CRDTTests
//
//  Created by Alin-Manuel GORGAN on 14/03/2021.
//

import Foundation
import CRDT
import XCTest

final class LwwElementGraphFailureTests: XCTestCase {
    
    func test_equals_DependentNotFound_itemsAreEqual_returnsTrue() {
        let lhsEntry = LwwElementGraph<Int>.Entry.node(1)
        let rhsEntry = LwwElementGraph<Int>.Entry.node(1)
        let lhsSubject = LwwElementGraph<Int>.Failure.DependentNotFound(lhsEntry)
        let rhsSubject = LwwElementGraph<Int>.Failure.DependentNotFound(rhsEntry)
        
        XCTAssertEqual(lhsSubject, rhsSubject)
    }
    
    func test_equals_DependentNotFound_itemsAreNotEqual_returnsFalse() {
        let lhsEntry = LwwElementGraph<Int>.Entry.node(1)
        let rhsEntry = LwwElementGraph<Int>.Entry.node(2)
        let lhsSubject = LwwElementGraph<Int>.Failure.DependentNotFound(lhsEntry)
        let rhsSubject = LwwElementGraph<Int>.Failure.DependentNotFound(rhsEntry)
        
        XCTAssertNotEqual(lhsSubject, rhsSubject)
    }
    
    func test_equals_DependentFound_itemsAreEqual_returnsTrue() {
        let lhsEntry = LwwElementGraph<Int>.Entry.node(1)
        let rhsEntry = LwwElementGraph<Int>.Entry.node(1)
        let lhsSubject = LwwElementGraph<Int>.Failure.DependentFound(lhsEntry)
        let rhsSubject = LwwElementGraph<Int>.Failure.DependentFound(rhsEntry)
        
        XCTAssertEqual(lhsSubject, rhsSubject)
    }
    
    func test_equals_DependentFound_itemsAreNotEqual_returnsFalse() {
        let lhsEntry = LwwElementGraph<Int>.Entry.node(1)
        let rhsEntry = LwwElementGraph<Int>.Entry.node(2)
        let lhsSubject = LwwElementGraph<Int>.Failure.DependentFound(lhsEntry)
        let rhsSubject = LwwElementGraph<Int>.Failure.DependentFound(rhsEntry)
        
        XCTAssertNotEqual(lhsSubject, rhsSubject)
    }
    
    func test_equals_DependentFound_DependentNotFound_itemsAreNotEqual_returnsFalse() {
        let lhsEntry = LwwElementGraph<Int>.Entry.node(1)
        let rhsEntry = LwwElementGraph<Int>.Entry.node(1)
        let lhsSubject = LwwElementGraph<Int>.Failure.DependentNotFound(lhsEntry)
        let rhsSubject = LwwElementGraph<Int>.Failure.DependentFound(rhsEntry)
        
        XCTAssertNotEqual(lhsSubject, rhsSubject)
    }
}

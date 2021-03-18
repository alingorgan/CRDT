
//
//  LwwElementGraphTests.swift
//  CRDTTests
//
//  Created by Alin-Manuel GORGAN on 13/03/2021.
//

import Foundation
import CRDT
import XCTest

final class LwwElementGraphTests: XCTestCase {
    
    // MARK: Graph addition testing.
    
    func test_addNode_additionIsSuccessfull() {
        var subject = LwwElementGraph<Int>()
        
        let result = subject.add(.node(1))
        
        if case .failure = result {
            XCTFail()
        }
    }
    
    func test_addEdge_nodesExist_additionIsSuccessfull() {
        var subject = LwwElementGraph<Int>()
        subject.add(.node(1))
        subject.add(.node(2))
        
        let result = subject.add(.edge(1, 2))
        
        if case .failure = result {
            XCTFail()
        }
    }
    
    func test_addEdge_firstDependentNodeMissing_additionFails() {
        var subject = LwwElementGraph<Int>()
        subject.add(.node(1))
        
        let result = subject.add(.edge(1, 2))
        
        if case .success = result {
            XCTFail()
        }
        
        guard
            case .failure(let genericError) = result,
            let error = genericError as? LwwElementGraph<Int>.Failure<Int>
        else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(error, .DependentNotFound(.node(2)))
    }
    
    func test_addEdge_secondDependentNodeMissing_additionFails() {
        var subject = LwwElementGraph<Int>()
        subject.add(.node(2))
        
        let result = subject.add(.edge(1, 2))
        
        if case .success = result {
            XCTFail()
        }
        
        guard
            case .failure(let genericError) = result,
            let error = genericError as? LwwElementGraph<Int>.Failure<Int>
        else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(error, .DependentNotFound(.node(1)))
    }
    
    // MARK: Graph removal testing.
    
    func test_removeNode_additionIsSuccessfull() {
        var subject = LwwElementGraph<Int>()
        
        let result = subject.remove(.node(1))
        
        guard
            case .failure(let genericError) = result,
            let error = genericError as? LwwElementSet<Int>.Failure
        else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(error, .ElementDoesNotExist)
    }
    
    func test_removeEdge_additionIsSuccessfull() {
        var subject = LwwElementGraph<Int>()
        subject.add(.node(1))
        subject.add(.node(2))
        
        let result = subject.remove(.edge(1, 2))
        
        guard
            case .failure(let genericError) = result,
            let error = genericError as? LwwElementSet<Pair<Int, Int>>.Failure
        else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(error, .ElementDoesNotExist)
    }
    
    func test_removeNode_dependentEdgeExists_removalFails() {
        var subject = LwwElementGraph<Int>()
        subject.add(.node(1))
        subject.add(.node(2))
        subject.add(.edge(1, 2))
        
        let result = subject.remove(.node(1))
        
        if case .success = result {
            XCTFail()
        }
        
        guard
            case .failure(let genericError) = result,
            let error = genericError as? LwwElementGraph<Int>.Failure<Int>
        else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(error, .DependentFound(.edge(1, 2)))
    }
    
    // MARK: Graph lookup testing.
    
    func test_containsNode_nodeExists_returnsTrue() {
        var subject = LwwElementGraph<Int>()
        subject.add(.node(1))
        subject.add(.node(2))

        XCTAssertTrue(subject.contains(.node(1)))
    }
    
    func test_containsNode_nodeIsMissing_returnsFalse() {
        var subject = LwwElementGraph<Int>()
        subject.add(.node(1))
        subject.remove(.node(1))

        XCTAssertFalse(subject.contains(.node(1)))
    }
    
    func test_containsEdge_edgeIsMissing_returnsFalse() {
        var subject = LwwElementGraph<Int>()
        subject.add(.node(1))
        subject.add(.node(2))

        XCTAssertFalse(subject.contains(.edge(1, 2)))
    }
    
    func test_containsEdge_edgeExists_returnsTrue() {
        var subject = LwwElementGraph<Int>()
        subject.add(.node(1))
        subject.add(.node(2))
        subject.add(.edge(1, 2))

        XCTAssertTrue(subject.contains(.edge(1, 2)))
    }
    
    // MARK: Graph all content testing.
    
    func test_all_nodesExists_EdgesExists_returnsAll() {
        var subject = LwwElementGraph<Int>()
        subject.add(.node(1))
        subject.add(.node(2))
        subject.add(.edge(1, 2))
        
        let expectedValue: Set<LwwElementGraph<Int>.Entry<Int>> = [
            .node(1),
            .node(2),
            .edge(1, 2)
        ]

        XCTAssertEqual(subject.all, expectedValue)
    }
    
    // MARK: Graph merge testing.
    
    func test_merge_nodesExist_edgesExist_resultIsCorrect() {
        var subject = LwwElementGraph<Int>()
        subject.add(.node(1))
        subject.add(.node(2))
        subject.add(.node(3))
        subject.add(.edge(1, 2))
        subject.add(.edge(2, 1))
        
        var otherGraph = LwwElementGraph<Int>()
        otherGraph.add(.node(1))
        otherGraph.add(.node(2))
        otherGraph.remove(.node(3))
        otherGraph.add(.edge(1, 2))
        otherGraph.remove(.edge(2, 1))
        otherGraph.add(.node(4))
        otherGraph.add(.node(5))
        otherGraph.add(.edge(4, 5))
        
        let result = subject.merging(otherGraph).all
        let expectedResult: Set<LwwElementGraph<Int>.Entry<Int>> = [
            .node(1),
            .node(2),
            .edge(1, 2),
            .node(4),
            .node(5),
            .edge(4, 5)
        ]
        
        XCTAssertEqual(result, expectedResult)
    }
    
    // MARK: Graph CRDT merge testing.
    
    func test_merge_associativity() {
        var A = LwwElementGraph<Int>()
        A.add(.node(1))
        A.add(.node(2))
        
        var B = LwwElementGraph<Int>()
        B.add(.node(1))
        B.add(.node(2))
        B.add(.edge(1, 2))
        
        var C = LwwElementGraph<Int>()
        C.add(.node(1))
        C.add(.node(2))
        C.add(.edge(1, 2))
        C.remove(.edge(1, 2))
        C.remove(.node(2))
        
        
        let AB = A.merging(B)
        let BC = B.merging(C)
        
        XCTAssertEqual(AB.merging(C), A.merging(BC))
    }
    
    func test_merge_commutativity() {
        var A = LwwElementGraph<Int>()
        A.add(.node(1))
        A.add(.node(2))
        
        var B = LwwElementGraph<Int>()
        B.add(.node(1))
        B.add(.node(2))
        B.add(.edge(1, 2))
        
        XCTAssertEqual(A.merging(B), B.merging(A))
    }
    
    func test_merge_idempotence() {
        var A = LwwElementGraph<Int>()
        A.add(.node(1))
        A.add(.node(2))
        
        var B = LwwElementGraph<Int>()
        B.add(.node(1))
        B.add(.node(2))
        B.add(.edge(1, 2))
        
        var C = LwwElementGraph<Int>()
        C.add(.node(1))
        C.add(.node(2))
        C.add(.edge(1, 2))
        C.remove(.edge(1, 2))
        C.remove(.node(2))
        
        
        let AB = A.merging(B)
        let ABC = AB.merging(C)
        let ABCA = ABC.merging(A)
        
        XCTAssertEqual(ABC, ABCA)
    }
}

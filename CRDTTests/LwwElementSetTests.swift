//
//  LwwElementSetTests.swift
//  CRDTTests
//
//  Created by Alin-Manuel GORGAN on 14/03/2021.
//

import Foundation
import CRDT
import XCTest

final class LwwElementSetTests: XCTestCase {
    
    var A: LwwElementSet<Int>!
    var B: LwwElementSet<Int>!
    var C: LwwElementSet<Int>!
    
    override func setUp() {
        super.setUp()
        
        A = LwwElementSet<Int>()
        A.add(1)
        A.add(2)
        
        B = LwwElementSet<Int>()
        B.add(1)
        B.remove(2)
        
        C = LwwElementSet<Int>()
        C.add(3)
        C.remove(2)
    }
    
    override func tearDown() {
        A = nil
        B = nil
        C = nil
        
        super.tearDown()
    }
    
    func test_add_additionSuccessfull() {
        if case .failure = A.add(4) {
            XCTFail()
        }
    }
    
    func test_remove_elementExists_removalSuccessfull() {
        A.add(2)
        
        if case .failure = A.remove(2) {
            XCTFail()
        }
    }
    
    func test_remove_elementDidNotExist_removeFails() {
        guard
            case .failure(let genericError) = A.remove(4),
            let error = genericError as? LwwElementSet<Int>.Failure
        else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(error, .ElementDoesNotExist)
    }
    
    func test_contains_elementExists_returnsTrue() {
        A.add(4)
        
        XCTAssertTrue(A.contains(4))
    }
    
    func test_contains_elementDoesNotExist_returnsFalse() {
        A.remove(2)
        
        XCTAssertFalse(A.contains(2))
    }
    
    func test_all_elementsExist_returnsAllElements() {
        let expectedResult: Set<Int> = [1, 2]
        XCTAssertEqual(A.all, expectedResult)
    }
    
    func test_merge_associativity() {
        let AB = A.merging(B)
        let BC = B.merging(C)
        
        XCTAssertEqual(AB.merging(C), A.merging(BC))
    }
    
    func test_merge_commutativity() {
        XCTAssertEqual(A.merging(B), B.merging(A))
    }
    
    func test_merge_idempotence() {
        let AB = A.merging(B)
        let ABC = AB.merging(C)
        let ABCA = ABC.merging(A)
        
        XCTAssertEqual(ABC, ABCA)
    }

}

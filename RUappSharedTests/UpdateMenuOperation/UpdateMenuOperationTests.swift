//
//  UpdateMenuOperationTests.swift
//  RUappSharedTests
//
//  Created by Igor Camilo on 18/02/18.
//  Copyright © 2018 Bit2 Technology. All rights reserved.
//

import XCTest
import CoreData
@testable import RUappShared

class UpdateMenuOperationTests: XCTestCase {
    
    var stack = PersistentContainerStub()
    
    override func setUp() {
        stack = PersistentContainerStub()
    }
    
    func testThatItWorks() {
        
        class TestExpectationOperation: Operation {
            let updateMenuOp: UpdateMenuOperation
            let expectation: XCTestExpectation
            init(updateMenuOp: UpdateMenuOperation, expectation: XCTestExpectation) {
                self.updateMenuOp = updateMenuOp
                self.expectation = expectation
            }
            override func main() {
                XCTAssertNil(updateMenuOp.error)
                XCTAssertEqual(updateMenuOp.cafeteria.menu?.count, 16)
                expectation.fulfill()
            }
        }
        
        let dataOp = URLSessionDataTaskOperation(url: Bundle(for: UpdateMenuOperationTests.self).url(forResource: "WorkingMenuDataStub", withExtension: "json"))
        let cafeteria = EntityStub.cafeteria(context: stack.viewContext)
        let updateMenuOp = UpdateMenuOperation(cafeteria: cafeteria, dataOp: dataOp)
        let testExpOp = TestExpectationOperation(updateMenuOp: updateMenuOp, expectation: expectation(description: "Expect operation to successfully update menu"))
        testExpOp.addDependency(updateMenuOp)
        OperationQueue.async.addOperation(updateMenuOp)
        OperationQueue.main.addOperation(testExpOp)
        waitForExpectations(timeout: 2, handler: nil)
    }
}
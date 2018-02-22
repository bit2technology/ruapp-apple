//
//  AsyncOperationTests.swift
//  RUappSharedTests
//
//  Created by Igor Camilo on 08/02/18.
//  Copyright © 2018 Bit2 Technology. All rights reserved.
//

import XCTest
@testable import RUappShared

class AsyncOperationTests: XCTestCase {

    func testThatItFinishes() {

        class StubOperation: AsyncOperation {
            override func main() {
                DispatchQueue(label: "StubQueue").asyncAfter(deadline: DispatchTime.now() + 1) {
                    self.finish()
                }
            }
        }

        class TestExpectationOperation: Operation {
            let exp: XCTestExpectation
            init(exp: XCTestExpectation) {
                self.exp = exp
                super.init()
            }
            override func main() {
                exp.fulfill()
            }
        }

        let exp = expectation(description: "Expect operation to finish")
        let stubOp = StubOperation()
        stubOp.name = "StubOperation"
        let testExpOp = TestExpectationOperation(exp: exp)
        testExpOp.addDependency(stubOp)
        OperationQueue.async.addOperation(stubOp)
        OperationQueue.main.addOperation(testExpOp)
        waitForExpectations(timeout: 2, handler: nil)
    }
}

//
//  AsyncOperationTests.swift
//  RUappSharedTests-iOS
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
        
        class TestStubOperation: Operation {
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
        let stub = StubOperation()
        stub.name = "StubOperation"
        let test = TestStubOperation(exp: exp)
        test.name = "TestStubOperation"
        test.addDependency(stub)
        let stubQ = OperationQueue()
        stubQ.name = "StubOperationQueue"
        stubQ.addOperation(stub)
        OperationQueue.main.addOperation(test)
        wait(for: [exp], timeout: 2)
    }
}

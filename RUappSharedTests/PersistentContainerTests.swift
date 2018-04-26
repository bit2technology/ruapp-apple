//
//  PersistentContainerTests.swift
//  RUappSharedTests
//
//  Created by Igor Camilo on 23/04/18.
//  Copyright © 2018 Bit2 Technology. All rights reserved.
//

import XCTest
import RUappShared

class PersistentContainerTests: XCTestCase {
    
    func testPersistentStoreLoad() {
        let persistentContainer = PersistentContainer.newInMemoryContainer()
        assert(persistentContainer.persistentStoreDescriptions.count == 1)
        let expectation = self.expectation(description: "Load persistent stores")
        persistentContainer.loadPersistentStores { (_, error) in
            if let error = error {
                assertionFailure(error.localizedDescription)
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
}

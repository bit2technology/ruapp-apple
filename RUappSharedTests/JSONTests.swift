//
//  JSONTests.swift
//  RUappSharedTests
//
//  Created by Igor Camilo on 13/09/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

import XCTest
@testable import RUappShared
import PromiseKit
import CoreData

class JSONTests: XCTestCase {

  var container: PersistentContainer!

  override func setUp() {
    let modelURL = Bundle(for: PersistentContainer.self).url(forResource: "Model", withExtension: "momd")!
    let model = NSManagedObjectModel(contentsOf: modelURL)!
    container = PersistentContainer(model: model)
    container.storeDescriptions = [(NSInMemoryStoreType, nil)]
  }

  func testMenu() {
    let exp = expectation(description: "Menu JSON test")
    let context = container.newBackgroundContext()
    let url = Bundle(for: JSONTests.self).url(forResource: "MenuStub", withExtension: "json")!
    let cafeteria = EntityStub.cafeteria(context: context)
    container.loadPersistentStore()
      .then { cafeteria.updateMenu(request: url) }
      .done {
        XCTAssertEqual($0.count, 16)
        XCTAssertEqual($0.count, cafeteria.menu?.count)
        exp.fulfill()
      }
      .catch { assertionFailure("Menu JSON test error: \($0.localizedDescription)") }
    waitForExpectations(timeout: 5)
  }
}

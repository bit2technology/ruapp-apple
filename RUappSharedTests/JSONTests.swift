//
//  JSONTests.swift
//  RUappSharedTests
//
//  Created by Igor Camilo on 13/09/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

import XCTest
@testable import RUappShared
import CoreData

class JSONTests: XCTestCase {

  var container: PersistentContainer!

  override func setUp() {
    let modelURL = Bundle(for: PersistentContainer.self).url(forResource: "Model", withExtension: "momd")!
    let model = NSManagedObjectModel(contentsOf: modelURL)!
    container = PersistentContainer(model: model)
    do {
      try container.coordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
    } catch {
      fatalError("Error loading persistent stores: \(error.localizedDescription)")
    }
  }

  func testMenu() {

    // Run
    let exp = expectation(description: "Menu JSON test")
    let context = container.newBackgroundContext()
    let url = Bundle(for: JSONTests.self).url(forResource: "MenuStub", withExtension: "json")
    let cafeteria = EntityStub.cafeteria(context: context)
    cafeteria.managedObjectContext?.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    let updateMenuOp = UpdateMenuOperation(cafeteria: cafeteria, dataOp: URLSessionDataTaskOperation(url: url))
    _ = ExpectationOperation(dep: updateMenuOp, exp: exp)
    waitForExpectations(timeout: 5)

    // Test
    let updateMenuResult = try! updateMenuOp.result()
    XCTAssertEqual(updateMenuResult.count, 16)
    XCTAssertEqual(updateMenuResult.count, cafeteria.menu?.count)
  }
}

class ExpectationOperation<T>: Operation {
  let dep: AsyncOperation<T>
  let exp: XCTestExpectation
  init(dep: AsyncOperation<T>, exp: XCTestExpectation) {
    self.dep = dep
    self.exp = exp
    super.init()
    addDependency(dep)
    OperationQueue.main.addOperation(self)
  }
  override func main() {
    print(dep.isFinished)
    exp.fulfill()
  }
}

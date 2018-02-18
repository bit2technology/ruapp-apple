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
    
    var stack: (NSManagedObjectModel, NSPersistentStoreCoordinator, NSManagedObjectContext)!
    
    override func setUp() {
        let model = NSManagedObjectModel(contentsOf: Bundle(for: Student.self).url(forResource: "Model", withExtension: "momd")!)!
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        try! coordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
        let viewContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        viewContext.persistentStoreCoordinator = coordinator
        stack = (model, coordinator, viewContext)
    }
    
    func testMenu() {
        
        let exp = expectation(description: "JSON")
        URLSession.shared.dataTask(with: URLRoute.menu(restaurantId: 1).urlRequest) { (data, response, error) in
            let ctx = self.stack.2
            ctx.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            let decoder = JSONDecoder.persistent(context: ctx)
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
            decoder.dateDecodingStrategy = .formatted(formatter)
            let dishes = try! decoder.decode([Meal].self, from: data!)
            print("Updated \(dishes.count) dishes")
            try! ctx.save()
            exp.fulfill()
        }.resume()
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testInstitutions() {
        
        let exp = expectation(description: "JSON")
        URLSession.shared.dataTask(with: URLRoute.getInstitutions.urlRequest) { (data, response, error) in
            let ctx = self.stack.2
            ctx.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            let decoder = JSONDecoder.persistent(context: ctx)
            let institutions = try! decoder.decode([Institution].self, from: data!)
            print("Updated \(institutions.count) institutions")
            try! ctx.save()
            exp.fulfill()
        }.resume()
        waitForExpectations(timeout: 5, handler: nil)
    }
}

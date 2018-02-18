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
    
    func testMenu() {
        
        let exp = expectation(description: "JSON")
        
        let modelURL = Bundle(for: Meal.self).url(forResource: "Model", withExtension: "momd")!
        print("modelURL", modelURL)
        let dbURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("Model.sqlite")
        print("dbURL", dbURL)
        let persistentCont = PersistentContainer.create(model: NSManagedObjectModel(contentsOf: modelURL)!, at: dbURL)
        persistentCont.loadPersistentStores { (err) in
            print(err)
            URLSession.shared.dataTask(with: URLRoute.menu(restaurantId: 1).urlRequest) { (data, response, error) in
                let ctx = persistentCont.newBackgroundContext()
                ctx.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                let decoder = JSONDecoder.persistent(context: ctx)
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "en_US_POSIX")
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
                decoder.dateDecodingStrategy = .formatted(formatter)
                let dishes = try! decoder.decode([Meal].self, from: data!)
                print(dishes)
                try! ctx.save()
                exp.fulfill()
            }.resume()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
}

//
//  Dish.swift
//  RUappShared-iOS
//
//  Created by Igor Camilo on 13/12/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

import Bit2Common
import CoreData

extension Dish: AdvancedManagedObjectProtocol {
    
    public typealias IDType = (Int64, Int64)
    public typealias RawType = ParsedRaw

    public static var entityName: String {
        return "Dish"
    }
    
    public static func uniquePredicate(withID id: (Int64, Int64)) -> NSPredicate {
        return NSPredicate(format: "meal.id = %lld AND order = %lld", id.0, id.1)
    }
    
    public func update(with raw: Dish.ParsedRaw) throws {
        type = raw.type
        meta = raw.meta
        name = raw.name
        order = raw.order
        mealId = raw.mealId
    }
    
    public struct ParsedRaw: AdvancedManagedObjectRawTypeProtocol {
        public typealias IDType = (Int64, Int64)
        var type: String
        var meta: String
        var name: String?
        var order: Int64
        var mealId: Int64
        public var advancedID: (Int64, Int64) {
            return (mealId, order)
        }
        
        init(from json: JSON.Menu.Meal.Dish, order: Int64, mealId: Int64) {
            type = json.type
            meta = json.meta
            name = json.name
            self.order = order
            self.mealId = mealId
        }
    }
}

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
    
    public typealias IDType = (String, String?)
    public typealias RawType = JSON.Meal.Dish

    public static var entityName: String {
        return "Dish"
    }
    
    public static func uniquePredicate(withID id: (String, String?)) -> NSPredicate {
        return NSPredicate(format: "type = %@ AND name = %@", id.0, id.1 ?? NSNull())
    }
    
    public func update(with raw: JSON.Meal.Dish) throws {
        type = raw.type
        meta = raw.meta
        name = raw.name
    }
}

extension JSON.Meal.Dish: AdvancedManagedObjectRawTypeProtocol {
    public typealias IDType = (String, String?)
    public var advancedID: (String, String?) { return (type, name) }
}

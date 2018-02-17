//
//  Meal.swift
//  RUappShared
//
//  Created by Igor Camilo on 12/11/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

import Bit2Common
import CoreData

extension JSON.Meal: AdvancedManagedObjectRawTypeProtocol {
    public typealias IDType = Int64
    public var advancedID: Int64 {
        return id
    }
}

extension Meal: AdvancedManagedObjectProtocol {
    public typealias IDType = Int64
    public typealias RawType = JSON.Meal

    public static var entityName: String {
        return "Meal"
    }
    
    public static func uniquePredicate(withID id: Int64) -> NSPredicate {
        return NSPredicate(format: "id = %lld", id)
    }
    
    public func update(with raw: JSON.Meal) throws {
        id = raw.id
        name = raw.name
        meta = raw.meta
        open = raw.open
        close = raw.close
        
        let oldDishes = (dishes?.array as? [Dish] ?? []).map { JSON.Meal.Dish(type: $0.type!, meta: $0.meta!, name: $0.name) }
        if (raw.dishes ?? []) != oldDishes {
            dishes?.forEach { managedObjectContext!.delete($0 as! Dish) }
            let newDishes = try raw.dishes?.map { (raw) -> Dish in
                let dish = Dish.new(with: managedObjectContext!)
                try dish.update(with: raw)
                return dish
            }
            dishes = NSOrderedSet(array: newDishes ?? [])
        }
    }
}

extension Meal {
    public static var next: Meal? {
        let req = request()
        req.predicate = NSPredicate(format: "close > %@", Date() as NSDate)
        req.sortDescriptors = [NSSortDescriptor(key: "close", ascending: true)]
        req.fetchLimit = 1
        return (try? CoreDataContainer.shared.viewContext.fetch(req))?.first
    }
}

extension JSON.Meal.Dish: Equatable {
    public static func ==(lhs: JSON.Meal.Dish, rhs: JSON.Meal.Dish) -> Bool {
        return (lhs.type == rhs.type) && (lhs.meta == rhs.meta) && (lhs.name == rhs.name)
    }
}

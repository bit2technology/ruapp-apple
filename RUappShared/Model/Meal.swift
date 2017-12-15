//
//  Meal.swift
//  RUappShared
//
//  Created by Igor Camilo on 12/11/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

import Bit2Common
import CoreData

extension Meal: AdvancedManagedObjectProtocol {
    
    public typealias IDType = Int64
    public typealias RawType = ParsedRaw

    public static var entityName: String {
        return "Meal"
    }
    
    public static func uniquePredicate(withID id: Int64) -> NSPredicate {
        return NSPredicate(format: "id = %lld", id)
    }
    
    public func update(with raw: ParsedRaw) throws {
        id = raw.advancedID
        name = raw.name
        meta = raw.meta
        open = raw.open
        close = raw.close
        if dishes!.count > raw.dishes.count {
            let dishesToDelete = (dishes as! Set<Dish>).filter { $0.order < raw.dishes.count }
            dishesToDelete.forEach { managedObjectContext!.delete($0) }
        }
        dishes = NSSet(array: try raw.dishes.map { try Dish.createOrUpdate(with: $0, context: managedObjectContext!) })
    }
    
    public struct ParsedRaw: AdvancedManagedObjectRawTypeProtocol {
        public typealias IDType = Int64
        public var advancedID: Int64
        var name: String
        var meta: String
        var open: Date
        var close: Date
        var dishes: [Dish.ParsedRaw]
        
        init?(from json: JSON.Menu.Meal, date: String) {
            
            guard let mealId = json.id, let mealOpen = json.open, let mealDuration = json.duration, let dishes = json.menu else {
                return nil
            }
            
            let advID = Int64(mealId)!
            advancedID = advID
            name = json.name
            meta = json.meta
            open = Meal.formatter.date(from: date + " " + mealOpen)!
            close = open.addingTimeInterval(TimeInterval(mealDuration))
            self.dishes = dishes.enumerated().map { Dish.ParsedRaw(from: $0.element, order: Int64($0.offset), mealId: advID) }
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
    
    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(identifier: "America/Sao_Paulo")
        return formatter
    }()
}

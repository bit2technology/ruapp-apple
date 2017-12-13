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
        return NSPredicate(format: "internald = %lld", id)
    }
    
    public func update(with raw: ParsedRaw) throws {
        internalId = raw.advancedID
        name = raw.name
        meta = raw.meta
        open = raw.open
        close = raw.close
    }
    
    public struct ParsedRaw: AdvancedManagedObjectRawTypeProtocol {
        public typealias IDType = Int64
        public var advancedID: Int64
        var name: String
        var meta: String
        var open: Date
        var close: Date
        
        init?(from meal: JSON.Menu.Meal, date: String) {
            
            guard let mealId = meal.id, let mealOpen = meal.open, let mealDuration = meal.duration else {
                return nil
            }
            
            advancedID = Int64(mealId)!
            name = meal.name
            meta = meal.meta
            open = Meal.formatter.date(from: date + " " + mealOpen)!
            close = open.addingTimeInterval(TimeInterval(mealDuration))
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

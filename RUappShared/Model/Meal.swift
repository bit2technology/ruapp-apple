//
//  Meal.swift
//  RUappShared
//
//  Created by Igor Camilo on 12/11/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

import CoreData

extension Meal {
    
    public static var next: Meal? {
        let fetchRequest: NSFetchRequest<Meal> = self.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "close > %@", Date() as NSDate)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "close", ascending: true)]
        fetchRequest.fetchLimit = 1
        return (try? PersistentContainer.shared.viewContext.fetch(fetchRequest))?.first
    }
    
    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(identifier: "America/Sao_Paulo")
        return formatter
    }()
    
    static func new(with context: NSManagedObjectContext) -> Meal {
        return NSEntityDescription.insertNewObject(forEntityName: "Meal", into: context) as! Meal
    }
    
    static func createOrUpdate(json: JSON.Menu.Meal, date: String, index: Int64, context: NSManagedObjectContext) throws -> Meal {
        let fetchRequest: NSFetchRequest<Meal> = self.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "internalId = %lld", date.dateInternalId(index: index))
        fetchRequest.fetchLimit = 1
        if let meal = (try context.fetch(fetchRequest)).first {
            return meal.update(from: json, date: date, index: index)
        } else {
            return self.new(with: context).update(from: json, date: date, index: index)
        }
    }
    
    @discardableResult func update(from json: JSON.Menu.Meal, date: String, index: Int64) -> Self {
        internalId = date.dateInternalId(index: index)
        name = json.name
        meta = json.meta
        if let open = json.open {
            self.open = Meal.formatter.date(from: date + " " + open)
            if let duration = json.duration {
                close = self.open?.addingTimeInterval(TimeInterval(duration * 60))
            } else {
                close = nil
            }
        } else {
            open = nil
        }
        return self
    }
}

private extension String {
    func dateInternalId(index: Int64) -> Int64 {
        return Int64(filter { $0 != "-" })! * 100 + index
    }
}

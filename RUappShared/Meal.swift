//
//  Meal.swift
//  RUappShared
//
//  Created by Igor Camilo on 12/11/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

import CoreData

@objc(Meal)
public class Meal: NSManagedObject, Decodable {
    
    static func nextRequest(for date: Date = Date()) -> NSFetchRequest<Meal> {
        let req: NSFetchRequest<Meal> = fetchRequest()
        req.predicate = NSPredicate(format: "close > %@", date as NSDate)
        req.sortDescriptors = [NSSortDescriptor(key: "close", ascending: true)]
        req.fetchLimit = 1
        return req
    }
    
    public required convenience init(from decoder: Decoder) throws {
        let context = decoder.userInfo[.managedObjectContext] as! NSManagedObjectContext
        self.init(entity: NSEntityDescription.entity(forEntityName: "Meal", in: context)!, insertInto: context)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int64.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        meta = try container.decode(String.self, forKey: .meta)
        open = try container.decode(Date.self, forKey: .open)
        close = try container.decode(Date.self, forKey: .close)
        dishes = try container.decodeIfPresent([Dish].self, forKey: .dishes)?.orderedSet()
        votables = try container.decodeIfPresent([Votable].self, forKey: .votables)?.orderedSet()
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case meta
        case open
        case close
        case dishes
        case votables
    }
}

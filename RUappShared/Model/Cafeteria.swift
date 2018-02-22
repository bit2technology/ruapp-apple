//
//  Cafeteria.swift
//  RUappShared
//
//  Created by Igor Camilo on 15/09/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

import CoreData

@objc(Cafeteria)
public class Cafeteria: NSManagedObject, Decodable {

    func nextMealRequest(for date: Date = Date()) -> NSFetchRequest<Meal> {
        let req: NSFetchRequest<Meal> = Meal.fetchRequest()
        req.predicate = NSPredicate(format: "cafeteria = %@ AND close > %@", self, date as NSDate)
        req.sortDescriptors = [NSSortDescriptor(key: "close", ascending: true)]
        req.fetchLimit = 1
        return req
    }

    public required convenience init(from decoder: Decoder) throws {
        let context = decoder.userInfo[.managedObjectContext] as! NSManagedObjectContext
        self.init(entity: NSEntityDescription.entity(forEntityName: "Cafeteria", in: context)!, insertInto: context)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int64.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        latitude = try container.decode(Double.self, forKey: .latitude)
        longitude = try container.decode(Double.self, forKey: .longitude)
        capacity = try container.decode(Int64.self, forKey: .capacity)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case latitude
        case longitude
        case capacity
    }
}

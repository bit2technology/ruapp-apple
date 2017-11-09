//
//  Cafeteria.swift
//  RUappShared
//
//  Created by Igor Camilo on 15/09/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

import CoreData

extension Cafeteria {
    
    static func new(with context: NSManagedObjectContext) -> Cafeteria {
        return NSEntityDescription.insertNewObject(forEntityName: "Cafeteria", into: context) as! Cafeteria
    }
    
    static func createOrUpdate(json: JSON.Institution.Campus.Restaurant, context: NSManagedObjectContext) throws -> Cafeteria {
        let fetchRequest: NSFetchRequest<Cafeteria> = self.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = %lld", Int64(json.id)!)
        fetchRequest.fetchLimit = 1
        if let cafeteria = (try context.fetch(fetchRequest)).first {
            return cafeteria.update(from: json)
        } else {
            return self.new(with: context).update(from: json)
        }
    }
    
    @discardableResult func update(from json: JSON.Institution.Campus.Restaurant) -> Self {
        id = Int64(json.id)!
        name = json.name
        latitude = Double(json.latitude)!
        longitude = Double(json.longitude)!
        capacity = Int64(json.capacity)!
        return self
    }
}

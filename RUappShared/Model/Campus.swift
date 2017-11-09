//
//  Campus.swift
//  RUappShared
//
//  Created by Igor Camilo on 17/09/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

import CoreData

extension Campus {
    
    static func new(with context: NSManagedObjectContext) -> Campus {
        return NSEntityDescription.insertNewObject(forEntityName: "Campus", into: context) as! Campus
    }
    
    static func createOrUpdate(json: JSON.Institution.Campus, context: NSManagedObjectContext) throws -> Campus {
        let fetchRequest: NSFetchRequest<Campus> = self.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = %lld", Int64(json.id)!)
        fetchRequest.fetchLimit = 1
        if let campus = (try context.fetch(fetchRequest)).first {
            return try campus.update(from: json)
        } else {
            return try self.new(with: context).update(from: json)
        }
    }
    
    @discardableResult func update(from json: JSON.Institution.Campus) throws -> Self {
        id = Int64(json.id)!
        name = json.name
        townName = json.townName
        stateName = json.stateName
        stateInitials = json.stateInitials
        cafeterias = NSSet(array: try json.restaurants.map { try Cafeteria.createOrUpdate(json: $0, context: managedObjectContext!) })
        return self
    }
}

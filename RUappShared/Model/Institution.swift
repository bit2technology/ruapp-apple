//
//  Institution.swift
//  RUappShared
//
//  Created by Igor Camilo on 14/09/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

import CoreData

extension Institution {
    
    static func new(with context: NSManagedObjectContext) -> Institution {
        return NSEntityDescription.insertNewObject(forEntityName: "Institution", into: context) as! Institution
    }
    
    static func createOrUpdate(json: JSON.Institution, context: NSManagedObjectContext) throws -> Institution {
        let fetchRequest: NSFetchRequest<Institution> = self.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = %lld", Int64(json.id)!)
        fetchRequest.fetchLimit = 1
        if let institution = (try context.fetch(fetchRequest)).first {
            return try institution.update(from: json)
        } else {
            return try self.new(with: context).update(from: json)
        }
    }
    
    @discardableResult func update(from json: JSON.Institution) throws -> Self {
        id = Int64(json.id)!
        name = json.name
        townName = json.townName
        stateName = json.stateName
        stateInitials = json.stateInitials
        if let campi = try json.campi?.map { try Campus.createOrUpdate(json: $0, context: managedObjectContext!) } {
            self.campi = NSSet(array: campi)
        } else {
            self.campi = nil
        }
        return self
    }
}

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
    
    @discardableResult func update(from json: JSON.Institution) -> Self {
        id = Int64(json.id)!
        name = json.name
        townName = json.townName
        stateName = json.stateName
        stateInitials = json.stateInitials
        campi = NSSet(array: (json.campi ?? []).map {
            let campus = NSEntityDescription.insertNewObject(forEntityName: Campus.entityName, into: managedObjectContext!) as! Campus
            campus.update(from: $0)
            return campus
        })
        return self
    }
}

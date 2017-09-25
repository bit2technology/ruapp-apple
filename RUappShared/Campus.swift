//
//  Campus.swift
//  RUappShared-iOS
//
//  Created by Igor Camilo on 17/09/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

import CoreData

extension Campus {
    static var entityName: String {
        return "Campus"
    }
}

/// Initializers
extension Campus {
    
    func update(from json: JSON.Institution.Campus) {
        id = Int64(json.id)!
        name = json.name
        townName = json.townName
        stateName = json.stateName
        stateInitials = json.stateInitials
        cafeterias = NSSet(array: json.restaurants.map {
            let cafeteria = NSEntityDescription.insertNewObject(forEntityName: Cafeteria.entityName, into: managedObjectContext!) as! Cafeteria
            cafeteria.update(from: $0)
            cafeteria.campus = self
            return cafeteria
        })
    }
}

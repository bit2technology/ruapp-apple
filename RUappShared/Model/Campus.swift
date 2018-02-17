//
//  Campus.swift
//  RUappShared
//
//  Created by Igor Camilo on 17/09/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

import Bit2Common
import CoreData

extension JSON.Institution.Campus: AdvancedManagedObjectRawTypeProtocol {
    public typealias IDType = Int64
    public var advancedID: Int64 {
        return id
    }
}

extension Campus: AdvancedManagedObjectProtocol {
    
    public typealias IDType = Int64
    public typealias RawType = JSON.Institution.Campus
    
    public static var entityName: String {
        return "Campus"
    }
    
    public static func uniquePredicate(withID id: Int64) -> NSPredicate {
        return NSPredicate(format: "id = %lld", id)
    }
    
    public func update(with raw: JSON.Institution.Campus) throws {
        id = raw.id
        name = raw.name
        townName = raw.townName
        stateName = raw.stateName
        stateInitials = raw.stateInitials
        cafeterias = NSSet(array: try raw.restaurants.map { try Cafeteria.createOrUpdate(with: $0, context: managedObjectContext!) })

    }
}

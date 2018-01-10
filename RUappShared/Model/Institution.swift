//
//  Institution.swift
//  RUappShared
//
//  Created by Igor Camilo on 14/09/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

import Bit2Common
import CoreData

extension JSON.Institution: AdvancedManagedObjectRawTypeProtocol {
    public typealias IDType = Int64
    public var advancedID: Int64 {
        return id
    }
}

extension Institution: AdvancedManagedObjectProtocol {
    
    public typealias IDType = Int64
    public typealias RawType = JSON.Institution
    
    public static var entityName: String {
        return "Institution"
    }
    
    public static func uniquePredicate(withID id: Int64) -> NSPredicate {
        return NSPredicate(format: "id = %lld", id)
    }
    
    public func update(with raw: JSON.Institution) throws {
        id = raw.advancedID
        name = raw.name
        townName = raw.townName
        stateName = raw.stateName
        stateInitials = raw.stateInitials
        campi = try NSSet(array: raw.campi.map { try Campus.createOrUpdate(with: $0, context: managedObjectContext!) })
    }
}

//
//  Cafeteria.swift
//  RUappShared
//
//  Created by Igor Camilo on 15/09/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

import Bit2Common
import CoreData

extension JSON.Institution.Campus.Restaurant: AdvancedManagedObjectRawTypeProtocol {
    public typealias IDType = Int64
    public var advancedID: Int64 {
        return Int64(id)!
    }
}

extension Cafeteria: AdvancedManagedObjectProtocol {
    
    public typealias IDType = Int64
    public typealias RawType = JSON.Institution.Campus.Restaurant
    
    public static var entityName: String {
        return "Cafeteria"
    }
    
    public static func uniquePredicate(withID id: Int64) -> NSPredicate {
        return NSPredicate(format: "id = %lld", id)
    }
    
    public func update(with raw: JSON.Institution.Campus.Restaurant) throws {
        id = raw.advancedID
        name = raw.name
        latitude = Double(raw.latitude)!
        longitude = Double(raw.longitude)!
        capacity = Int64(raw.capacity)!
    }
}

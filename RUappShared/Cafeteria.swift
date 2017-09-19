//
//  Cafeteria.swift
//  RUappShared
//
//  Created by Igor Camilo on 15/09/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

import CoreData

extension Cafeteria {
    static var entityName: String {
        return "Cafeteria"
    }
}

/// Initializers
extension Cafeteria {
    
    func update(from json: JSONInstitution.Campus.Restaurant) {
        id = Int64(json.id)!
        name = json.name
        latitude = Double(json.latitude)!
        longitude = Double(json.longitude)!
        capacity = Int64(json.capacity)!
    }
}

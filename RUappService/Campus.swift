//
//  Campus.swift
//  RUapp
//
//  Created by Igor Camilo on 15-09-23.
//  Copyright © 2015 Igor Camilo. All rights reserved.
//

// This class represents a campus of an institution.
open class Campus {
    
    /// Initialization by plist.
    init(dict: AnyObject) throws {
        // Verify fields
        guard let
            id = dict["id"] as? Int,
            let name = dict["name"] as? String,
            let restaurantsDict = dict["restaurants"] as? [AnyObject] else {
                throw Error.invalidObject
        }
        
        var restaurants = [Restaurant]()
        for dict in restaurantsDict {
            restaurants.append(try Restaurant(dict: dict))
        }
        // Initialize proprieties
        self.id = id
        self.name = name
        self.restaurants = restaurants
    }
    
    // MARK: Instance
    
    /// Id of the campus.
    open let id: Int
    /// Name of the campus.
    open let name: String
    /// List of the restaurants of this campus.
    open let restaurants: [Restaurant]
    
    /// Campus errors
    enum Error: Swift.Error {
        case invalidObject
    }
}

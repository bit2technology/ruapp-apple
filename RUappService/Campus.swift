//
//  Campus.swift
//  RUapp
//
//  Created by Igor Camilo on 15-09-23.
//  Copyright © 2015 Igor Camilo. All rights reserved.
//

// This class represents a campus of an institution.
public class Campus {
    
    // Private keys
    private static let idKey = "id"
    private static let nameKey = "name"
    private static let restaurantsKey = "restaurants"
    
    // MARK: Instance
    
    /// Id of the campus.
    public let id: Int
    /// Name of the campus.
    public let name: String
    /// List of the restaurants of this campus.
    public let restaurants: [Restaurant]
    
    /// Initialization by values.
    private init(id: Int, name: String, restaurants: [Restaurant]) {
        self.id = id
        self.name = name
        self.restaurants = restaurants
    }
    
    /// Initialization by plist.
    convenience init(dict: AnyObject?) throws {
        // Verify fields
        guard let
            id = dict?[Campus.idKey] as? Int,
            name = dict?[Campus.nameKey] as? String,
            restaurantsDict = dict?[Campus.restaurantsKey] as? [AnyObject] else {
                throw Error.InvalidObject
        }
        
        var restaurants = [Restaurant]()
        for dict in restaurantsDict {
            restaurants.append(try Restaurant(dict: dict))
        }
        self.init(id: id, name: name, restaurants: restaurants)
    }
    
    /// Campus errors
    enum Error: ErrorType {
        case InvalidObject
    }
}
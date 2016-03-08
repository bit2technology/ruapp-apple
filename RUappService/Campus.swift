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
    
    public let id: Int
    public let name: String
    public let restaurants: [Restaurant]
    
    private init(id: Int, name: String, restaurants: [Restaurant]) {
        self.id = id
        self.name = name
        self.restaurants = restaurants
    }
    
    convenience init(dict: AnyObject?) throws {
        
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
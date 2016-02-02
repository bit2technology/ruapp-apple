//
//  Campus.swift
//  RUapp
//
//  Created by Igor Camilo on 15-09-23.
//  Copyright © 2015 Igor Camilo. All rights reserved.
//

public class Campus {
    
    public let id: Int
    public let name: String
    public let restaurants: [Restaurant]
    
    public init(dict: AnyObject?) throws {
        do {
            guard let dict = dict as? [String:AnyObject],
                dictInt = dict["id"] as? Int,
                dictName = dict["name"] as? String,
                dictRestaurant = dict["restaurants"] as? [[String:AnyObject]] else {
                    throw Error.InvalidObject
            }
            
            var restaurantArray = [Restaurant]()
            for restaurant in dictRestaurant {
                restaurantArray.append(try Restaurant(dict: restaurant))
            }
            id = dictInt
            name = dictName
            restaurants = restaurantArray
        }
        catch {
            id = -1
            name = ""
            restaurants = []
            throw error
        }
    }
}
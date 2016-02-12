//
//  Restaurant.swift
//  RUapp
//
//  Created by Igor Camilo on 15-09-23.
//  Copyright © 2015 Igor Camilo. All rights reserved.
//

import CoreLocation

private let DefaultRestaurantIdKey = "DefaultRestaurantId"

public class Restaurant {
    
    public static var defaultRestaurantId = globalUserDefaults?.objectForKey(DefaultRestaurantIdKey) as? Int {
        didSet {
            if let defaultRestaurantId = defaultRestaurantId {
                globalUserDefaults?.setInteger(defaultRestaurantId, forKey: DefaultRestaurantIdKey)
                globalUserDefaults?.synchronize()
            }
        }
    }
    
    public let id: Int
    public let name: String
    public let capacity: Int?
    public let coordinate: CLLocationCoordinate2D
    
    public init(dict: AnyObject?) throws {
        
        guard let dict = dict as? [String:AnyObject],
            dictId = dict["id"] as? Int,
            dictName = dict["name"] as? String,
            latitude = dict["latitude"] as? CLLocationDegrees,
            longitude = dict["longitude"] as? CLLocationDegrees else {
                throw Error.InvalidObject
        }
        
        id = dictId
        name = dictName
        capacity = dict["capacity"] as? Int
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
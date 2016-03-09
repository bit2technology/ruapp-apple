//
//  Restaurant.swift
//  RUapp
//
//  Created by Igor Camilo on 15-09-23.
//  Copyright © 2015 Igor Camilo. All rights reserved.
//

import CoreLocation

/// This class represents a restaurant of a campus.
public class Restaurant {
    
    /// Internal reference to user default.
    private static weak var _userDefault = Restaurant.getUserDefault() {
        didSet {
            if let newDefaultRestaurant = _userDefault {
                // Save to disk
                globalUserDefaults.setInteger(newDefaultRestaurant.id, forKey: userDefaultIdKey)
                globalUserDefaults.synchronize()
                NSNotificationCenter.defaultCenter().postNotificationName(userDefaultIdKey, object: self)
            }
        }
    }
    
    /// Reference to the user's default restaurant.
    public static var userDefault: Restaurant? {
        get {
            if _userDefault == nil {
                // If _userDefault is nil, try to get it from disk and return it
                _userDefault = getUserDefault()
            }
            return _userDefault
        }
        set {
            _userDefault = newValue
        }
    }
    
    /// Notification name for when the default restaurant changes.
    public static let UserDefaultChangedNotification = "UserDefaultRestaurantChangedNotification"
    
    // Private keys
    private static let userDefaultIdKey = "user_default_restaurant"
    private static let idKey = "id"
    private static let nameKey = "name"
    private static let latitudeKey = "latitude"
    private static let longitudeKey = "longitude"
    private static let capacityKey = "capacity"
    
    /// Get saved user default from disk.
    private class func getUserDefault() -> Restaurant? {
        // Verify fields
        guard let campi = Institution.shared?.campi else {
            return nil
        }
        // Find restaurant by id
        let defaultRestaurantId = globalUserDefaults.objectForKey(userDefaultIdKey) as? Int
        var firstFound: Restaurant?
        for campus in campi {
            for rest in campus.restaurants {
                if rest.id == defaultRestaurantId {
                    return rest
                }
                if firstFound == nil {
                    firstFound = rest
                }
            }
        }
        // If cannot find the restaurant
        return firstFound
    }
    
    // MARK: Instance
    
    /// Id of the restaurant.
    public let id: Int
    /// Name of the restaurant.
    public let name: String
    /// Capacity of the restaurant.
    public let capacity: Int?
    /// Map coordinates of the restaurant.
    public let coordinate: CLLocationCoordinate2D
    
    /// Initialization by values.
    private init(id: Int, name: String, capacity: Int?, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        self.id = id
        self.name = name
        self.capacity = capacity
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    /// Initialization by plist.
    convenience init(dict: AnyObject?) throws {
        // Verify fields
        guard let
            id = dict?[Restaurant.idKey] as? Int,
            name = dict?[Restaurant.nameKey] as? String,
            latitude = dict?[Restaurant.latitudeKey] as? CLLocationDegrees,
            longitude = dict?[Restaurant.longitudeKey] as? CLLocationDegrees else {
                throw Error.InvalidObject
        }
        self.init(id: id, name: name, capacity: dict?[Restaurant.capacityKey] as? Int, latitude: latitude, longitude: longitude)
    }
    
    /// Campus errors
    enum Error: ErrorType {
        case InvalidObject
    }
}
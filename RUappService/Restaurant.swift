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
                NSNotificationCenter.defaultCenter().postNotificationName(UserDefaultChangedNotification, object: self)
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
    private static let userDefaultIdKey = "saved_user_default_restaurant"
    
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
    
    /// Initialization by plist.
    init(dict: AnyObject) throws {
        // Verify fields
        guard let
            id = dict["id"] as? Int,
            name = dict["name"] as? String,
            latitude = dict["latitude"] as? CLLocationDegrees,
            longitude = dict["longitude"] as? CLLocationDegrees else {
                throw Error.InvalidObject
        }
        // Initialize proprieties
        self.id = id
        self.name = name
        self.capacity = dict["capacity"] as? Int
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
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
    
    /// Campus errors
    enum Error: ErrorType {
        case InvalidObject
    }
}
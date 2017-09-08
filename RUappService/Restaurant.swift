
import CoreLocation

/// This class represents a restaurant of a campus.
open class Restaurant {
    
    /// Internal reference to user default.
    fileprivate static weak var _userDefault = Restaurant.getUserDefault() {
        didSet {
            if let newDefaultRestaurant = _userDefault {
                // Save to disk
                globalUserDefaults.set(newDefaultRestaurant.id, forKey: userDefaultIdKey)
                globalUserDefaults.synchronize()
                NotificationCenter.default.post(name: Notification.Name(rawValue: UserDefaultChangedNotification), object: self)
            }
        }
    }
    
    /// Reference to the user's default restaurant.
    open static var userDefault: Restaurant? {
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
    open static let UserDefaultChangedNotification = "UserDefaultRestaurantChangedNotification"
    
    // Private keys
    fileprivate static let userDefaultIdKey = "saved_user_default_restaurant"
    
    /// Get saved user default from disk.
    fileprivate class func getUserDefault() -> Restaurant? {
        // Verify fields
        guard let campi = Institution.shared?.campi else {
            return nil
        }
        // Find restaurant by id
        let defaultRestaurantId = globalUserDefaults.object(forKey: userDefaultIdKey) as? Int
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
        guard let rawId = dict["id"] as? String, let id = Int(rawId), let name = dict["name"] as? String, let rawLatitude = dict["latitude"] as? String, let latitude = CLLocationDegrees(rawLatitude), let rawLongitude = dict["longitude"] as? String, let longitude = CLLocationDegrees(rawLongitude) else {
            throw Error.invalidObject
        }
        // Initialize proprieties
        self.id = id
        self.name = name
        self.capacity = Int(dict["capacity"] as? String ?? "")
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    // MARK: Instance
    
    /// Id of the restaurant.
    open let id: Int
    /// Name of the restaurant.
    open let name: String
    /// Capacity of the restaurant.
    open let capacity: Int?
    /// Map coordinates of the restaurant.
    open let coordinate: CLLocationCoordinate2D
    
    /// Campus errors
    enum Error: Swift.Error {
        case invalidObject
    }
}

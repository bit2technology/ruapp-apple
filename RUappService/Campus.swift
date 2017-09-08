
// This class represents a campus of an institution.
open class Campus {
    
    /// Initialization by plist.
    init(dict: AnyObject) throws {
        // Verify fields
        guard let rawId = dict["id"] as? String, let id = Int(rawId), let name = dict["name"] as? String, let restaurantsDict = dict["restaurants"] as? [AnyObject] else {
            throw Error.invalidObject
        }
        
        // Initialize proprieties
        self.id = id
        self.name = name
        self.restaurants = try restaurantsDict.map(Restaurant.init)
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

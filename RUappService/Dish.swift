
/// This class represents a dish of a meal
open class Dish {
    
    /// Initialize by plist
    init(dict: AnyObject) throws {
        // Verify values
        guard let rawMeta = dict["meta"] as? String,
            let meta = Meta(rawValue: rawMeta),
            let type = dict["type"] as? String else {
                throw Error.invalidObject
        }
        // Initialize proprieties
        self.meta = meta
        self.type = type
        self.name = dict["name"] as? String
    }
    
    // MARK: Instance
    
    /// Meta info of the dish.
    open let meta: Meta
    /// Type of the dish.
    open let type: String
    /// Name of the dish.
    open let name: String?
    
    /// This enum represents if a dish is in the vegetarian menu.
    public enum Meta: String {
        case main = "main" // Not vegetarian
        case vegetarian = "vegetarian"
        case other = "other" // Both
    }
    
    /// Dish error.
    enum Error: Swift.Error {
        case invalidObject
    }
}

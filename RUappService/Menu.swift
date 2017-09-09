
import Alamofire

/// Class to manage menu data.
open class Menu {
    
    /// Private keys
    fileprivate static let savedArrayKey = "saved_menu_array"
    fileprivate static let savedKindKey = "saved_menu_kind"
    fileprivate static let restaurantIdKey = "restaurant_id"
    fileprivate static let mealsKey = "meals"
    fileprivate static let dateKey = "date"
    
    /// Default menu kind set by the user.
    open static var defaultKind = Kind(rawValue: globalUserDefaults.object(forKey: savedKindKey) as? Int ?? Kind.traditional.rawValue)! {
        didSet {
            globalUserDefaults.set(defaultKind.rawValue, forKey: savedKindKey)
            globalUserDefaults.synchronize()
        }
    }
    
//    func mealOpening() -> (previous: Meal?, next: Meal?) {
//        var previousMeal: Meal?
//        let now = NSDate()
//        for menuDay in meals {
//            for meal in menuDay {
//                if now.timeIntervalSinceDate(meal.opening) < 0 {
//                    return (previousMeal, meal)
//                }
//                previousMeal = meal
//            }
//        }
//        return (previousMeal, nil)
//    }
    
    // FIXME: Make it work properly
    /// Meal for current time, if any.
    open var currentMeal: Meal? {
//        let meals = mealOpening()
//        return meals.previous?.closing?.timeIntervalSinceNow > 0 ? meals.previous : nil
        return meals[0][1]
    }
    
    fileprivate static func saved() throws -> [String : Any] {
        guard let saved = globalUserDefaults.object(forKey: savedArrayKey) else {
            throw Error.noData
        }
        guard let savedDict = saved as? [String : Any] else {
            throw Error.invalidObject
        }
        return savedDict
    }
    
    /// Shared menu data. It is also cached for offline query.
    open fileprivate(set) static var shared = try? Menu(dict: saved())
    
    /// Reference to current request.
    fileprivate static var request: Request?
    
    /// Prevent requesting too often.
    fileprivate static var lastSuccessfulRequest = Date(timeIntervalSince1970: 0) // Initial time set to past, so we can update on load.
    
    /// Initialize by plist.
    fileprivate init(dict: [String : Any]) throws {
        // Verify values
        guard let restaurantId = dict[Menu.restaurantIdKey] as? Int,
            let rawWeekMenu = dict[Menu.mealsKey] as? [AnyObject] else {
                throw Error.invalidObject
        }
        // Initialize proprieties
        self.meals = try rawWeekMenu.map {
            // Verify meal values
            guard let dateString = $0[Menu.dateKey] as? String, let rawMeals = $0[Menu.mealsKey] as? [AnyObject], rawMeals.count > 0 else {
                throw Error.invalidObject
            }
            return try rawMeals.map { try Meal(dict: $0, dateString: dateString) }
        }
        self.restaurantId = restaurantId
    }
    
    // MARK: Instance
    
    /// Info about meals of this menu.
    open fileprivate(set) var meals: [[Meal]]
    
    /// Restaurant id for verification.
    open fileprivate(set) var restaurantId: Int
    
    /// Get menu info from data. If successfull, cache it.
    open class func update(_ restaurant: Restaurant, completion: @escaping (_ result: Result<Menu>) -> Void) {
        
        // If request for the same restaurant, prevent requesting too often (if there is an active request or the last request was less than 1min ago)
        if restaurant.id == shared?.restaurantId && (request != nil || Date().timeIntervalSince(lastSuccessfulRequest) < 60) {
            completion(Result.failure(error: Error.requestTooOften))
            return
        }
        
        // Cancel current request (if any) and start a new one.
        request?.cancel()
        request = Alamofire.request(ServiceURL.getMenu, parameters: [Menu.restaurantIdKey: restaurant.id]).responseJSON { (response) in
            request = nil
            
            do {
                // Verify data
                guard let rawMenu = response.result.value, response.result.isSuccess else {
                    throw response.result.error ?? Error.noData
                }
                
                // Process menu data. If successful, save it to user defaults.
                let extendedMenu = [Menu.mealsKey: rawMenu, Menu.restaurantIdKey: restaurant.id]
                let newMenu = try Menu(dict: extendedMenu)
                Menu.shared = newMenu
                globalUserDefaults.set(extendedMenu, forKey: savedArrayKey)
                globalUserDefaults.synchronize()
                
                // Return menu
                lastSuccessfulRequest = Date()
                completion(.success(value: newMenu))
            } catch {
                // Return error
                completion(.failure(error: error))
            }
        }
    }
    
    /// Kind of menu.
    public enum Kind: Int {
        case traditional = 0
        case vegetarian = 1
    }
    
    /// Menu error.
    enum Error: Swift.Error {
        case invalidObject
        case noData
        case requestTooOften
    }
}

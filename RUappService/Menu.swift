//
//  Menu.swift
//  RUapp
//
//  Created by Igor Camilo on 15-11-09.
//  Copyright © 2015 Igor Camilo. All rights reserved.
//

import Alamofire

/// Class to manage menu data.
public class Menu {
    
    /// Private keys
    private static let savedArrayKey = "saved_menu_array"
    private static let savedKindKey = "saved_menu_kind"
    private static let restaurantIdKey = "restaurant_id"
    private static let mealsKey = "meals"
    private static let dateKey = "date"
    
    /// Default menu kind set by the user.
    public static var defaultKind = Kind(rawValue: globalUserDefaults.objectForKey(savedKindKey) as? Int ?? Kind.Traditional.rawValue)! {
        didSet {
            globalUserDefaults.setInteger(defaultKind.rawValue, forKey: savedKindKey)
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
    public var currentMeal: Meal? {
//        let meals = mealOpening()
//        return meals.previous?.closing?.timeIntervalSinceNow > 0 ? meals.previous : nil
        return meals[0][1]
    }
    
    /// Shared menu data. It is also cached for offline query.
    public private(set) static var shared = try? Menu(dict: globalUserDefaults.objectForKey(savedArrayKey))
    
    /// Reference to current request.
    private static var request: Request?
    
    /// Prevent requesting too often.
    private static var lastSuccessfulRequest = NSDate(timeIntervalSince1970: 0) // Initial time set to past, so we can update on load.
    
    /// Initialize by plist.
    private init(dict: AnyObject?) throws {
        // Verify values
        guard let restaurantId = dict?[Menu.restaurantIdKey] as? Int,
            rawWeekMenu = dict?[Menu.mealsKey] as? [AnyObject] else {
                throw Error.InvalidObject
        }
        // Construct menu matrix
        var weekMenu = [[Meal]]()
        for rawDayMenu in rawWeekMenu {
            // Verify meal values
            guard let
                dateString = rawDayMenu[Menu.dateKey] as? String,
                rawMeals = rawDayMenu[Menu.mealsKey] as? [AnyObject] where rawMeals.count > 0 else {
                    throw Error.InvalidObject
            }
            // Construct inner array
            var dayMenu = [Meal]()
            for rawMeal in rawMeals {
                dayMenu.append(try Meal(dict: rawMeal, dateString: dateString))
            }
            weekMenu.append(dayMenu)
        }
        // Initialize proprieties
        self.meals = weekMenu
        self.restaurantId = restaurantId
    }
    
    // MARK: Instance
    
    /// Info about meals of this menu.
    public private(set) var meals: [[Meal]]
    
    /// Restaurant id for verification.
    public private(set) var restaurantId: Int
    
    /// Get menu info from data. If successfull, cache it.
    public class func update(restaurant: Restaurant, completion: (result: Result<Menu>) -> Void) {
        
        // If request for the same restaurant, prevent requesting too often (if there is an active request or the last request was less than 1min ago)
        if restaurant.id == shared?.restaurantId && (request != nil || NSDate().timeIntervalSinceDate(lastSuccessfulRequest) < 60) {
            completion(result: Result.Failure(error: Error.RequestTooOften))
            return
        }
        
        // Cancel current request (if any) and start a new one.
        request?.cancel()
        request = Alamofire.request(.GET, ServiceURL.getMenu, parameters: [Menu.restaurantIdKey: restaurant.id]).responseJSON { (response) in
            request = nil
            
            do {
                // Verify data
                guard let rawMenu = response.result.value where response.result.isSuccess else {
                    throw response.result.error ?? Error.NoData
                }
                
                // Process menu data. If successful, save it to user defaults.
                let extendedMenu = [Menu.mealsKey: rawMenu, Menu.restaurantIdKey: restaurant.id]
                let newMenu = try Menu(dict: extendedMenu)
                Menu.shared = newMenu
                globalUserDefaults.setObject(extendedMenu, forKey: savedArrayKey)
                globalUserDefaults.synchronize()
                
                // Return menu
                lastSuccessfulRequest = NSDate()
                completion(result: .Success(value: newMenu))
            } catch {
                // Return error
                completion(result: .Failure(error: error))
            }
        }
    }
    
    /// Kind of menu.
    public enum Kind: Int {
        case Traditional = 0
        case Vegetarian = 1
    }
    
    /// Menu error.
    enum Error: ErrorType {
        case InvalidObject
        case NoData
        case RequestTooOften
    }
}

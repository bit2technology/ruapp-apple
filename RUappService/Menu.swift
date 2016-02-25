//
//  Menu.swift
//  RUapp
//
//  Created by Igor Camilo on 15-11-09.
//  Copyright © 2015 Igor Camilo. All rights reserved.
//

import Alamofire

/// Key used to save and get cached menu data.
private let SavedMenuArrayKey = "SavedMenuArray"

/// Key used to save and get cached menu kind.
private let SavedMenuKindKey = "SavedMenuKind"

/// Class to manage menu data.
public class Menu {
    
    /// Default menu kind set by the user.
    public static var defaultKind = Kind(rawValue: globalUserDefaults?.objectForKey(SavedMenuKindKey) as? Int ?? Kind.Traditional.rawValue)! {
        didSet {
            globalUserDefaults?.setInteger(defaultKind.rawValue, forKey: SavedMenuKindKey)
            globalUserDefaults?.synchronize()
        }
    }
    
    /// Shared menu data. It is also cached for offline query.
    public private(set) static var shared = try? Menu(menuObj: globalUserDefaults?.objectForKey(SavedMenuArrayKey))
    
    /// Reference to current request.
    private static var request: Request?
    
    /// Prevent requesting too often.
    private static var lastSuccessfulRequest = NSDate(timeIntervalSince1970: 0) // Initial time set to past, so we can update on load.
    
    /// Info about meals of this menu.
    public private(set) var meals: [[Meal]]
    
    /// Restaurant id for verification.
    public private(set) var restaurantId: Int
    
    /// Get menu info from data. If successfull, cache it.
    public class func update(restaurant: Restaurant, completion: (menu: Menu?, error: ErrorType?) -> Void) {
        print("update started")
        
        // If request for the same restaurant, prevent requesting too often (if there is an active request or the last request was less than 1min ago)
        if restaurant.id == shared?.restaurantId && (request != nil || NSDate().timeIntervalSinceDate(lastSuccessfulRequest) < 60) {
            completion(menu: nil, error: Error.RequestTooOften)
            return
        }
        
        // Cancel current request (if any) and start a new one.
        request?.cancel()
        request = Alamofire.request(.GET, ServiceURL.getMenu, parameters: ["restaurant_id": restaurant.id]).responseJSON { (response) in
            request = nil
            print("update ended success:", response.result.isSuccess)
            
            do {
                // Verify data
                guard let rawMenu = response.result.value where response.result.isSuccess else {
                    throw response.result.error ?? Error.NoData
                }
                
                // Process menu data. If successful, save it to user defaults.
                let extendedMenu = ["meals": rawMenu, "restaurant_id": restaurant.id]
                Menu.shared = try Menu(menuObj: extendedMenu)
                globalUserDefaults?.setObject(extendedMenu, forKey: SavedMenuArrayKey)
                globalUserDefaults?.synchronize()
                
                // Return menu
                lastSuccessfulRequest = NSDate()
                completion(menu: Menu.shared, error: nil)
            } catch {
                // Return error
                completion(menu: nil, error: error)
            }
        }
    }
    
    private init(menuObj: AnyObject?) throws {
        
        guard let restaurantId = menuObj?["restaurant_id"] as? Int,
            rawWeekMenu = menuObj?["meals"] as? [AnyObject] else {
                throw Error.InvalidObject
        }
        
        var weekMenu = [[Meal]]()
        for rawDayMenu in rawWeekMenu {
            
            guard let dateString = rawDayMenu["date"] as? String,
                rawMeals = rawDayMenu["meals"] as? [AnyObject] where rawMeals.count > 0 else {
                    throw Error.InvalidObject
            }
            
            var dayMenu = [Meal]()
            for rawMeal in rawMeals {
                dayMenu.append(try Meal(dict: rawMeal, dateString: dateString))
            }
            
            weekMenu.append(dayMenu)
        }
        
        self.meals = weekMenu
        self.restaurantId = restaurantId
    }
    
    /// Kind of menu.
    public enum Kind: Int {
        case Traditional = 0
        case Vegetarian = 1
    }
}

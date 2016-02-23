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

private let SavedMenuRestaurantIdKey = "SavedMenuRestaurantId"

private let SavedMenuKindKey = "SavedMenuKind"

/// Helper class to manage menu data
public class Menu {
    
    public static var defaultKind = Kind(rawValue: globalUserDefaults?.objectForKey(SavedMenuKindKey) as? Int ?? Kind.Traditional.rawValue)! {
        didSet {
            globalUserDefaults?.setInteger(defaultKind.rawValue, forKey: SavedMenuKindKey)
            globalUserDefaults?.synchronize()
        }
    }
    
    /// Shared menu data. It is also cached for offline query.
    public private(set) static var shared = try? Menu(rawMenu: globalUserDefaults?.objectForKey(SavedMenuArrayKey), restaurantId: nil)
    
    
    public private(set) var restaurantId: Int?
    
    
    public private(set) var meals: [[Meal]]
    
    /// Get menu info from data. If successfull, cache it.
    public class func update(restaurant: Restaurant, completion: (menu: Menu?, error: ErrorType?) -> Void) {
        Alamofire.request(.GET, ServiceURL.getMenu, parameters: ["restaurant_id": restaurant.id]).responseJSON { (response) in
            do {
                // Verify data
                guard response.result.isSuccess else {
                    throw response.result.error ?? Error.NoData
                }
                
                // Process menu data. If successful, save it to user defaults.
                let rawMenu = response.result.value
                let menu = try Menu(rawMenu: rawMenu, restaurantId: restaurant.id)
                globalUserDefaults?.setObject(rawMenu, forKey: SavedMenuArrayKey)
                globalUserDefaults?.synchronize()
                
                // Return menu
                completion(menu: menu, error: nil)
            } catch {
                // Return error
                completion(menu: nil, error: error)
            }
        }
    }
    
    /// Process raw menu data.
    private class func process(menuObj: AnyObject?) throws -> [[Meal]] {
        
        guard let rawWeekMenu = menuObj as? [AnyObject] else {
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
        
        return weekMenu
    }
    
    private init(rawMenu: AnyObject?, restaurantId: Int?) throws {
        
        if let restaurantId = restaurantId {
            globalUserDefaults?.setInteger(restaurantId, forKey: SavedMenuRestaurantIdKey)
            globalUserDefaults?.synchronize()
        }
        
        self.meals = try Menu.process(rawMenu)
        self.restaurantId = restaurantId ?? globalUserDefaults?.objectForKey(SavedMenuRestaurantIdKey) as? Int
    }
    
    public enum Kind: Int {
        case Traditional = 0
        case Vegetarian = 1
    }
}

//
//  Menu.swift
//  RUapp
//
//  Created by Igor Camilo on 15-11-09.
//  Copyright © 2015 Igor Camilo. All rights reserved.
//

/// Key used to save and get cached menu data.
private let SavedMenuArrayKey = "SavedMenuArray"

/// Helper class to manage menu data
public class Menu {
    
    /// Shared menu data. It is also cached for offline query.
    public private(set) static var shared = try? Menu.process(globalUserDefaults?.dictionaryForKey(SavedMenuArrayKey))
    
    /// Get menu info from data. If successfull, cache it.
    public class func update(cafeteria: Cafeteria, completion: (menu: [[Meal]]?, error: ErrorType?) -> Void) {
        NSURLSession.sharedSession().dataTaskWithURL(NSURL.appGetMenu(cafeteria), completionHandler: { (data, response, error) -> Void in
            do {
                // Verify data
                guard let data = data else {
                    throw error ?? Error.NoData
                }
                
                // Process menu data. If successful, save it to user defaults.
                let rawMenu = try NSJSONSerialization.JSONObjectWithData(data, options: [])
                let menu = try process(rawMenu)
                globalUserDefaults?.setObject(rawMenu, forKey: SavedMenuArrayKey)
                globalUserDefaults?.synchronize()
                
                // Return menu
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    completion(menu: menu, error: nil)
                })
            } catch {
                // Return error
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    completion(menu: nil, error: error)
                })
            }
        }).resume()
    }
    
    /// Get current or next meal.
    public class func currentMeal() -> Meal? {
        
        // Verify if there is already menu data
        guard let menu = shared else {
            return nil
        }
        
        // Search for current or next meal
        for meals in menu {
            for meal in meals {
                
            }
        }
        
        // Current or next meal not found
        return nil
    }
    
    /// Process raw menu data.
    private class func process(menuObj: AnyObject?) throws -> [[Meal]] {
        
        guard let menuArray = menuObj as? [AnyObject] else {
            throw Error.InvalidObject
        }
        
        var menu = [[Meal]]()
        for rawDay in menuArray {
            
            guard let dateString = rawDay["data"] as? String,
                let rawMeals = rawDay["refeicoes"] as? [AnyObject] else {
                    throw Error.InvalidObject
            }
            
            var meals = [Meal]()
            for rawMeal in rawMeals {
                meals.append(try Meal(dict: rawMeal, dateString: dateString))
            }
            menu.append(meals)
        }
        return menu
    }
}

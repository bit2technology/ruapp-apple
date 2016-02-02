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
    public private(set) static var shared = try? Menu.process(globalUserDefaults?.objectForKey(SavedMenuArrayKey))
    
    /// Get menu info from data. If successfull, cache it.
    public class func update(restaurantId: Int, completion: (menu: [[Meal]]?, error: ErrorType?) -> Void) {
        NSURLSession.sharedSession().dataTaskWithURL(NSURL.appGetMenu(restaurantId), completionHandler: { (data, response, error) -> Void in
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
    
    /// Process raw menu data.
    private class func process(menuObj: AnyObject?) throws -> [[Meal]] {
        
        guard let rawWeekMenu = menuObj as? [AnyObject] else {
            throw Error.InvalidObject
        }
        
        var weekMenu = [[Meal]]()
        for rawDayMenu in rawWeekMenu {
            
            guard let dateString = rawDayMenu["date"] as? String,
                rawMeals = rawDayMenu["meals"] as? [AnyObject] else {
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
}

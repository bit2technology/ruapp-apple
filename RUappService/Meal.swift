//
//  Meal.swift
//  RUapp
//
//  Created by Igor Camilo on 15-09-23.
//  Copyright © 2015 Igor Camilo. All rights reserved.
//

public class Meal {
    
    private static let dateFormatter = mealDateFormatter()
    
    public let name: String
    public let meta: Meta
    public let id: Int?
    public let openingDate: NSDate?
    public let closingDate: NSDate?
    public let dishes: [Dish]?
    
    init(dict: AnyObject?, dateString: String) throws {
        do {
            guard let dict = dict as? [String:AnyObject],
                dictName = dict["name"] as? String,
                rawMeta = dict["meta"] as? String,
                dictMeta = Meta(rawValue: rawMeta) else {
                    throw Error.InvalidObject
            }
            
            // Dishes
            if let rawDishes = dict["menu"] as? [[String:AnyObject]] {
                var menuConstructor = [Dish]()
                for rawDish in rawDishes {
                    menuConstructor.append(try Dish(dict: rawDish))
                }
                dishes = menuConstructor
            } else {
                dishes = nil
            }
            
            // Opening and closing times
            openingDate = Meal.dateFormatter.dateFromString(dateString + " " + (dict["open"] as? String ?? "00:00:00"))
            if let closingStr = dict["duration"] as? Double {
                closingDate = openingDate?.dateByAddingTimeInterval(closingStr * 60)
            } else {
                closingDate = nil
            }
            
            name = dictName
            meta = dictMeta
            id = dict["id"] as? Int
        }
        catch {
            name = ""
            meta = .None
            id = nil
            openingDate = NSDate()
            closingDate = nil
            dishes = nil
            throw error
        }
    }
    
    public enum Meta: String {
        case Open = "open"
        case Closed = "closed"
        case Strike = "strike"
        case None = "-"
    }
}

private func mealDateFormatter() -> NSDateFormatter {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return dateFormatter
}
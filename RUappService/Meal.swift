//
//  Meal.swift
//  RUapp
//
//  Created by Igor Camilo on 15-09-23.
//  Copyright © 2015 Igor Camilo. All rights reserved.
//

public class Meal {
    
    /// Reference to the NSDateFormatter used to create opening and closing dates for the meals.
    private static let dateFormatter = { () -> NSDateFormatter in
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter
    }()
    
    // MARK: Instance
    
    /// Id of the meal.
    public let id: Int?
    /// Name of the meal.
    public let name: String
    /// Meta info of the meal.
    public let meta: Meta
    /// Opening date of the restaurant for this meal.
    public let opening: NSDate
    /// Closing date of the restaurant for this meal.
    public let closing: NSDate?
    /// List of dishes for this meal.
    public let dishes: [Dish]?
    /// List of votables for this meal.
    public let votables: [Votable]?
    
    /// Initialize by values.
    private init(id: Int?, name: String, meta: Meta, opening: NSDate, closing: NSDate?, dishes: [Dish]?, votables: [Votable]?) {
        self.id = id
        self.name = name
        self.meta = meta
        self.opening = opening
        self.closing = closing
        self.dishes = dishes
        self.votables = votables
    }
    
    /// Initialize by plist.
    convenience init(dict: AnyObject, dateString: String) throws {
        // Verify fields
        guard let
            opening = Meal.dateFormatter.dateFromString(dateString + " " + (dict["open"] as? String ?? "00:00:00")),
            name = dict["name"] as? String else {
                throw Error.InvalidObject
        }
        // Closing time
        let closing: NSDate?
        if let closingStr = dict["duration"] as? Double {
            closing = opening.dateByAddingTimeInterval(closingStr * 60)
        } else {
            closing = nil
        }
        // Meta
        let meta: Meta
        if let rawMeta = dict["meta"] as? String, dictMeta = Meta(rawValue: rawMeta) {
            meta = dictMeta
        } else {
            meta = .Closed
        }
        // Dishes
        var dishes: [Dish]?
        if let rawDishes = dict["menu"] as? [AnyObject] {
            dishes = [Dish]()
            for rawDish in rawDishes {
                dishes!.append(try Dish(dict: rawDish))
            }
        }
        // Votables
        var votables: [Votable]?
        if let rawVotables = dict["votables"] as? [AnyObject] {
            votables = [Votable]()
            for rawVotable in rawVotables {
                votables!.append(try Votable(dict: rawVotable))
            }
        }
        // Init
        self.init(id: dict["id"] as? Int, name: name, meta: meta, opening: opening, closing: closing, dishes: dishes, votables: votables)
    }
    
    /// This enum represents the status of the restaurant for this meal.
    public enum Meta: String {
        case Open = "open"
        case Closed = "closed"
        case Strike = "strike"
    }
    
    /// Meal error.
    enum Error: ErrorType {
        case InvalidObject
    }
}
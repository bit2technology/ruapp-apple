//
//  Meal.swift
//  RUapp
//
//  Created by Igor Camilo on 15-09-23.
//  Copyright © 2015 Igor Camilo. All rights reserved.
//

open class Meal {
    
    /// Reference to the NSDateFormatter used to create opening and closing dates for the meals.
    fileprivate static let dateFormatter = { () -> DateFormatter in
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter
    }()
    
    /// Initialize by plist.
    init(dict: AnyObject, dateString: String) throws {
        // Verify fields
        guard let
            opening = Meal.dateFormatter.date(from: dateString + " " + (dict["open"] as? String ?? "00:00:00")),
            let name = dict["name"] as? String else {
                throw Error.invalidObject
        }
        // Closing time
        let closing: Date?
        if let closingStr = dict["duration"] as? Double {
            closing = opening.addingTimeInterval(closingStr * 60)
        } else {
            closing = nil
        }
        // Meta
        let meta: Meta
        if let rawMeta = dict["meta"] as? String, let dictMeta = Meta(rawValue: rawMeta) {
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
        // Initialize proprieties
        self.id = dict["id"] as? Int
        self.name = name
        self.meta = meta
        self.opening = opening
        self.closing = closing
        self.dishes = dishes
        self.votables = votables
    }
    
    // MARK: Instance
    
    /// Id of the meal.
    open let id: Int?
    /// Name of the meal.
    open let name: String
    /// Meta info of the meal.
    open let meta: Meta
    /// Opening date of the restaurant for this meal.
    open let opening: Date
    /// Closing date of the restaurant for this meal.
    open let closing: Date?
    /// List of dishes for this meal.
    open let dishes: [Dish]?
    /// List of votables for this meal.
    open let votables: [Votable]?
    
    /// This enum represents the status of the restaurant for this meal.
    public enum Meta: String {
        case Open = "open"
        case Closed = "closed"
        case Strike = "strike"
    }
    
    /// Meal error.
    enum Error: Swift.Error {
        case invalidObject
    }
}

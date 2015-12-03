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
    public let openingDate: NSDate
    public let closingDate: NSDate?
    public let dishes: [Dish]?
    
    init(dict: AnyObject?, dateString: String) throws {
        do {
            guard let dict = dict as? [String:AnyObject],
                dictName = dict["nome"] as? String,
                dictOpeningDate = Meal.dateFormatter.dateFromString(dateString + " " + (dict["hora_abertura"] as? String ?? "00:00:00")) else {
                    throw Error.InvalidObject
            }
            
            // Dishes
            if let rawDishes = dict["cardapio"] as? [[String:AnyObject]] {
                var menuConstructor = [Dish]()
                for rawDish in rawDishes {
                    menuConstructor.append(try Dish(dict: rawDish))
                }
                dishes = menuConstructor
            } else {
                dishes = nil
            }
            
            name = dictName
            openingDate = dictOpeningDate
            if let closingStr = dict["minutos_fechamento"] as? Double {
                closingDate = openingDate.dateByAddingTimeInterval(closingStr * 60)
            } else {
                closingDate = nil
            }
            
        }
        catch {
            name = ""
            openingDate = NSDate()
            closingDate = nil
            dishes = nil
            throw error
        }
    }
}

private func mealDateFormatter() -> NSDateFormatter {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return dateFormatter
}
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
    public let closingDate: NSDate
    
    init(dict: AnyObject?, dateString: String) throws {
        do {
            guard let dict = dict as? [String:AnyObject],
                dictName = dict["nome"] as? String,
                opening = dict["hora_abertura"] as? String,
                openingDate = Meal.dateFormatter.dateFromString(dateString + " " + opening),
                closing = dict["minutos_fechamento"] as? Double else {
                    throw Error.InvalidObject
            }
            name = dictName
            self.openingDate = openingDate
            self.closingDate = openingDate.dateByAddingTimeInterval(closing * 60)
        }
        catch {
            name = ""
            openingDate = NSDate()
            closingDate = openingDate
            throw error
        }
    }
}

private func mealDateFormatter() -> NSDateFormatter {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
    return dateFormatter
}
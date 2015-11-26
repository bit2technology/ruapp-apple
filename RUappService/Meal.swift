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
    public let labelDate: NSDate
    public let openingDate: NSDate?
    public let closingDate: NSDate?
    
    init(dict: AnyObject?, dateString: String) throws {
        do {
            guard let dict = dict as? [String:AnyObject],
                dictName = dict["nome"] as? String,
                date = Meal.dateFormatter.dateFromString(dateString + " 00:00") else {
                    throw Error.InvalidObject
            }
            name = dictName
            labelDate = date
            if let openingStr = dict["hora_abertura"] as? String {
                openingDate = Meal.dateFormatter.dateFromString(dateString + " " + openingStr)
            } else {
                openingDate = nil
            }
            if let closingStr = dict["minutos_fechamento"] as? Double {
                closingDate = openingDate?.dateByAddingTimeInterval(closingStr * 60)
            } else {
                closingDate = nil
            }
        }
        catch {
            name = ""
            labelDate = NSDate()
            openingDate = nil
            closingDate = nil
            throw error
        }
    }
}

private func mealDateFormatter() -> NSDateFormatter {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
    return dateFormatter
}
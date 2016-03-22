//
//  Dish.swift
//  RUapp
//
//  Created by Igor Camilo on 15-11-30.
//  Copyright © 2015 Igor Camilo. All rights reserved.
//

/// This class represents a dish of a meal
public class Dish {
    
    /// Initialize by plist
    init(dict: AnyObject) throws {
        // Verify values
        guard let rawMeta = dict["meta"] as? String,
            meta = Meta(rawValue: rawMeta),
            type = dict["type"] as? String else {
                throw Error.InvalidObject
        }
        // Initialize proprieties
        self.meta = meta
        self.type = type
        self.name = dict["name"] as? String
    }
    
    // MARK: Instance
    
    /// Meta info of the dish.
    public let meta: Meta
    /// Type of the dish.
    public let type: String
    /// Name of the dish.
    public let name: String?
    
    /// This enum represents if a dish is in the vegetarian menu.
    public enum Meta: String {
        case Main = "main" // Not vegetarian
        case Vegetarian = "vegetarian"
        case Other = "other" // Both
    }
    
    /// Dish error.
    enum Error: ErrorType {
        case InvalidObject
    }
}

//
//  Dish.swift
//  RUapp
//
//  Created by Igor Camilo on 15-11-30.
//  Copyright © 2015 Igor Camilo. All rights reserved.
//

public class Dish {
    
    public let meta: Meta
    public let type: String
    public let name: String?
    
    init(dict: [String:AnyObject]) throws {
        
        guard let rawMeta = dict["meta"] as? String,
            meta = Meta(rawValue: rawMeta),
            type = dict["type"] as? String else {
                self.meta = .Other
                self.type = ""
                self.name = nil
                throw Error.InvalidObject
        }
        
        self.meta = meta
        self.type = type
        
        if let name = dict["name"] as? String {
            self.name = name
        } else {
            self.name = nil
        }
    }
    
    public enum Meta: String {
        case Main = "main"
        case Vegetarian = "vegetarian"
        case Other = "other"
    }
}

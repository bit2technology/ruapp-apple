//
//  Votable.swift
//  RUapp
//
//  Created by Igor Camilo on 16-03-09.
//  Copyright © 2016 Igor Camilo. All rights reserved.
//

public class Votable {
    
    public let id: Int
    public let meta: Dish.Meta
    public let name: String
    
    init(dict: AnyObject) throws {
        
        guard let
            id = dict["id"] as? Int,
            rawMeta = dict["meta"] as? String,
            meta = Dish.Meta(rawValue: rawMeta),
            name = dict["name"] as? String else {
                throw Error.InvalidObject
        }
        
        self.id = id
        self.meta = meta
        self.name = name
    }
    
    /// Votable error.
    enum Error: ErrorType {
        case InvalidObject
    }
}
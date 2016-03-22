//
//  Votable.swift
//  RUapp
//
//  Created by Igor Camilo on 16-03-09.
//  Copyright © 2016 Igor Camilo. All rights reserved.
//

public class Votable {
    
    /// Initialize by plist
    init(dict: AnyObject) throws {
        // Verify values
        guard let
            id = dict["id"] as? Int,
            rawMeta = dict["meta"] as? String,
            meta = Dish.Meta(rawValue: rawMeta),
            name = dict["name"] as? String else {
                throw Error.InvalidObject
        }
        // Initialize proprieties
        self.id = id
        self.meta = meta
        self.name = name
    }
    
    // MARK: Instance
    
    /// Id of the votable item.
    public let id: Int
    /// Meta info of the votable item.
    public let meta: Dish.Meta
    /// Name of the votable item.
    public let name: String
    
    /// Votable error.
    enum Error: ErrorType {
        case InvalidObject
    }
}
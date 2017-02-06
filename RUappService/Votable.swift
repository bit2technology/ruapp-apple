//
//  Votable.swift
//  RUapp
//
//  Created by Igor Camilo on 16-03-09.
//  Copyright © 2016 Igor Camilo. All rights reserved.
//

open class Votable {
    
    /// Initialize by plist
    init(dict: AnyObject) throws {
        // Verify values
        guard let
            id = dict["id"] as? Int,
            let rawMeta = dict["meta"] as? String,
            let meta = Dish.Meta(rawValue: rawMeta),
            let name = dict["name"] as? String else {
                throw Error.invalidObject
        }
        // Initialize proprieties
        self.id = id
        self.meta = meta
        self.name = name
    }
    
    // MARK: Instance
    
    /// Id of the votable item.
    open let id: Int
    /// Meta info of the votable item.
    open let meta: Dish.Meta
    /// Name of the votable item.
    open let name: String
    
    /// Votable error.
    enum Error: Swift.Error {
        case invalidObject
    }
}

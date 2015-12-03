//
//  Dish.swift
//  RUapp
//
//  Created by Igor Camilo on 15-11-30.
//  Copyright © 2015 Igor Camilo. All rights reserved.
//

public class Dish {
    
    public let id: Int
    public let meta: Meta
    public let type: String
    public let name: String?
    
    init(dict: [String:AnyObject]) throws {
        
        guard let id = dict["comida_id"] as? Int,
            rawMeta = dict["meta"] as? String,
            meta = Meta(rawValue: rawMeta),
            type = dict["tipo_comida_nome"] as? String else {
                self.id = 0
                self.meta = .Other
                self.type = ""
                self.name = nil
                throw Error.InvalidObject
        }
        
        self.id = id
        self.meta = meta
        self.type = type
        
        if let name = dict["comida_nome"] as? String {
            self.name = name
        } else {
            self.name = nil
        }
    }
    
    public enum Meta: String {
        case Main = "principal"
        case Vegetarian = "vegetariano"
        case Other = "outro"
    }
}

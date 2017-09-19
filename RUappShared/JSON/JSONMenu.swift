//
//  JSONMenu.swift
//  RUappShared
//
//  Created by Igor Camilo on 13/09/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

struct JSONMenu: Codable {
    var date: String
    var meals: [Meal]
    
    struct Meal: Codable {
        var name: String
        var id: String?
        var meta: String
        var open: String?
        var duration: Int?
        var menu: [Dish]?
        var votables: [Votable]?
        
        struct Dish: Codable {
            var type: String
            var meta: String
            var name: String?
        }
        
        struct Votable: Codable {
            var name: String
            var meta: String
            var id: String
        }
    }
}

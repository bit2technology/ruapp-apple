//
//  JSONMenu.swift
//  RUappShared
//
//  Created by Igor Camilo on 13/09/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

struct JSONMenu: Decodable {
    var date: String
    var meals: [Meal]
    
    struct Meal: Decodable {
        var name: String
        var id: String?
        var meta: String
        var open: String?
        var duration: Int?
        var menu: [Dish]?
        var votables: [Votable]?
        
        struct Dish: Decodable {
            var type: String
            var meta: String
            var name: String?
        }
        
        struct Votable: Decodable {
            var name: String
            var meta: String
            var id: String
        }
    }
}

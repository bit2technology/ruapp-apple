//
//  JSONResult.swift
//  RUappShared
//
//  Created by Igor Camilo on 13/09/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

struct JSONResult: Codable {
    var mealName: String
    var results: [Dish]
    
    enum CodingKeys: String, CodingKey {
        case mealName = "meal_name"
        case results
    }
    
    struct Dish: Codable {
        var name: String
        var iconId: String
        var meta: String
        var counters: [Counter]
        
        enum CodingKeys: String, CodingKey {
            case name = "dish_name"
            case iconId = "dish_icon_id"
            case meta
            case counters
        }
        
        struct Counter: Codable {
            var id: String
            var count: String
            
            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                id = try container.decode(String.self, forKey: .id)
                // Fix for count, which can be Number or String
                if let intCount = try? container.decode(Int.self, forKey: .count) {
                    count = String(intCount)
                } else {
                    count = try container.decode(String.self, forKey: .count)
                }
            }
        }
    }
}

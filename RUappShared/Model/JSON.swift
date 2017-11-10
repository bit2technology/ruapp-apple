//
//  JSON.swift
//  RUappShared
//
//  Created by Igor Camilo on 23/09/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

/// Raw API request and response data.
enum JSON {
    
    struct Menu: Decodable {
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
    
    struct Institution: Decodable {
        var id: String
        var name: String
        var townName: String?
        var stateName: String?
        var stateInitials: String?
        var campi: [Campus]?
        
        enum CodingKeys: String, CodingKey {
            case id
            case name
            case townName = "town_name"
            case stateName = "state_name"
            case stateInitials = "state_initials"
            case campi
        }
        
        struct Campus: Decodable {
            var id: String
            var name: String
            var townName: String
            var stateName: String
            var stateInitials: String
            var restaurants: [Restaurant]
            
            enum CodingKeys: String, CodingKey {
                case id
                case name
                case townName = "town_name"
                case stateName = "state_name"
                case stateInitials = "state_initials"
                case restaurants
            }
            
            struct Restaurant: Decodable {
                var id: String
                var name: String
                var latitude: String
                var longitude: String
                var capacity: String
            }
        }
    }
    
    struct Result: Decodable {
        var mealName: String
        var results: [Dish]
        
        enum CodingKeys: String, CodingKey {
            case mealName = "meal_name"
            case results
        }
        
        struct Dish: Decodable {
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
            
            struct Counter: Decodable {
                var id: String
                var count: String
                
                enum CodingKeys: String, CodingKey {
                    case id
                    case count
                }
                
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
    
    struct Student: Encodable {
        var name: String
        var numberPlate: String
        var institutionId: Int64
        
        enum CodingKeys: String, CodingKey {
            case name
            case numberPlate = "number_plate"
            case institutionId = "institution_id"
        }
    }
    
    struct RegisteredStudent: Decodable {
        var studentId: Int64
        var institution: Institution
        
        enum CodingKeys: String, CodingKey {
            case studentId = "student_id"
            case institution
        }
    }
    
    struct Vote: Encodable {
        var mealId: Int
        var studentId: Int
        var votes: [Dish]
        
        enum CodingKeys: String, CodingKey {
            case mealId = "meal_id"
            case studentId = "student_id"
            case votes
        }
        
        struct Dish: Encodable {
            var voteTypeId: Int
            var id: Int
            var comment: String
            var preDefinedCommentIds: Set<Int>
            
            enum CodingKeys: String, CodingKey {
                case voteTypeId = "vote_type_id"
                case id = "dish_id"
                case comment
                case preDefinedCommentIds = "pre_defined_comment_ids"
            }
        }
    }
}

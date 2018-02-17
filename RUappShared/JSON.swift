//
//  JSON.swift
//  RUappShared
//
//  Created by Igor Camilo on 23/09/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

import Foundation

public enum JSON {
    
    public struct Meal: Decodable {
        var id: Int64
        var name: String
        var meta: String
        var open: Date
        var close: Date
        var dishes: [Dish]?
        var votables: [Votable]?
        
        public struct Dish: Decodable {
            var type: String
            var meta: String
            var name: String?
        }
        
        struct Votable: Decodable {
            var name: String
            var meta: String
            var id: Int64
        }
    }
    
    public struct Institution: Decodable {
        var id: Int64
        var name: String
        var townName: String
        var stateName: String
        var stateInitials: String
        var campi: [Campus]
        
        enum CodingKeys: String, CodingKey {
            case id
            case name
            case townName = "town_name"
            case stateName = "state_name"
            case stateInitials = "state_initials"
            case campi
        }
        
        public struct Campus: Decodable {
            var id: Int64
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
            
            public struct Restaurant: Decodable {
                var id: Int64
                var name: String
                var latitude: Double
                var longitude: Double
                var capacity: Int64
            }
        }
    }
    
    public struct Student: Encodable {
        var id: Int64
        var name: String
        var numberPlate: String
        var institutionId: Int64
        
        enum CodingKeys: String, CodingKey {
            case id
            case name
            case numberPlate = "number_plate"
            case institutionId = "institution_id"
        }
    }
}

//
//  JSONInstitution.swift
//  RUappShared
//
//  Created by Igor Camilo on 13/09/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

struct JSONInstitution: Codable {
    var id: String
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
    
    struct Campus: Codable {
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
        
        struct Restaurant: Codable {
            var id: String
            var name: String
            var latitude: String
            var longitude: String
            var capacity: String
        }
    }
    
    struct Overview {
        var id: String
        var name: String
    }
}

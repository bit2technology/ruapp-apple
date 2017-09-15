//
//  Cafeteria.swift
//  RUappShared
//
//  Created by Igor Camilo on 15/09/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

public final class Cafeteria {
    
    let id: String
    
    init(json: JSONInstitution.Campus.Restaurant) {
        id = json.id
    }
}

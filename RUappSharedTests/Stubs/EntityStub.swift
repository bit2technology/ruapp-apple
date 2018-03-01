//
//  EntityStub.swift
//  RUappSharedTests-iOS
//
//  Created by Igor Camilo on 20/02/18.
//  Copyright © 2018 Bit2 Technology. All rights reserved.
//

import CoreData
@testable import RUappShared

class EntityStub {

    static func institution(context: NSManagedObjectContext) -> Institution {
        let institution = Institution(context: context)
        institution.id = 1
        institution.name = "Stub"
        institution.stateInitials = "Stub"
        institution.stateName = "Stub"
        institution.townName = "Stub"
        return institution
    }

    static func campus(context: NSManagedObjectContext) -> Campus {
        let campus = Campus(context: context)
        campus.id = 1
        campus.name = "Stub"
        campus.stateInitials = "Stub"
        campus.stateName = "Stub"
        campus.townName = "Stub"
        campus.institution = institution(context: context)
        return campus
    }

    static func cafeteria(context: NSManagedObjectContext) -> Cafeteria {
        let cafeteria = Cafeteria(context: context)
        cafeteria.id = 1
        cafeteria.capacity = 0
        cafeteria.latitude = 0
        cafeteria.longitude = 0
        cafeteria.name = "Stub"
        cafeteria.campus = campus(context: context)
        return cafeteria
    }
}

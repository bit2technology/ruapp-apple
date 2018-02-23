//
//  Institution.swift
//  RUappShared
//
//  Created by Igor Camilo on 14/09/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

import CoreData

@objc(Institution)
public class Institution: NSManagedObject, Decodable {

    public convenience init(context: NSManagedObjectContext) {
        self.init(entity: NSEntityDescription.entity(forEntityName: "Institution", in: context)!, insertInto: context)
    }

    public required convenience init(from decoder: Decoder) throws {
        let context = decoder.userInfo[.managedObjectContext] as! NSManagedObjectContext
        self.init(context: context)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int64.self, forKey: .identifier)
        name = try container.decode(String.self, forKey: .name)
        townName = try container.decode(String.self, forKey: .townName)
        stateName = try container.decode(String.self, forKey: .stateName)
        stateInitials = try container.decode(String.self, forKey: .stateInitials)
        campi = try NSSet(array: container.decode([Campus].self, forKey: .campi))
    }

    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case name
        case townName = "town_name"
        case stateName = "state_name"
        case stateInitials = "state_initials"
        case campi
    }
}

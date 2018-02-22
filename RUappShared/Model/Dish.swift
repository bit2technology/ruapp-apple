//
//  Dish.swift
//  RUappShared
//
//  Created by Igor Camilo on 13/12/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

import CoreData

@objc(Dish)
public class Dish: NSManagedObject, Decodable {

    public required convenience init(from decoder: Decoder) throws {
        let context = decoder.userInfo[.managedObjectContext] as! NSManagedObjectContext
        self.init(entity: NSEntityDescription.entity(forEntityName: "Dish", in: context)!, insertInto: context)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(String.self, forKey: .type)
        meta = try container.decode(String.self, forKey: .meta)
        name = try container.decodeIfPresent(String.self, forKey: .name)
    }

    enum CodingKeys: String, CodingKey {
        case type
        case meta
        case name
    }
}

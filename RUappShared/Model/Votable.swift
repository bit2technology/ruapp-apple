//
//  Votable.swift
//  RUappShared
//
//  Created by Igor Camilo on 18/02/18.
//  Copyright © 2018 Bit2 Technology. All rights reserved.
//

import CoreData

@objc(Votable)
public class Votable: NSManagedObject, Decodable {
    
    public required convenience init(from decoder: Decoder) throws {
        let context = decoder.userInfo[.managedObjectContext] as! NSManagedObjectContext
        self.init(entity: NSEntityDescription.entity(forEntityName: "Votable", in: context)!, insertInto: context)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int64.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        meta = try container.decode(String.self, forKey: .meta)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case meta
    }
}
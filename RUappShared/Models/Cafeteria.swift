//
//  Cafeteria.swift
//  RUappShared
//
//  Created by Igor Camilo on 15/09/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

import CoreData

@objc(Cafeteria)
public final class Cafeteria: NSManagedObject { }

extension Cafeteria: NamedManagedObject {
  public static var entityName: String {
    return "Cafeteria"
  }
}

extension Cafeteria: Decodable {

  public convenience init(from decoder: Decoder) throws {
    let context = decoder.userInfo[.managedObjectContext] as! NSManagedObjectContext
    self.init(context: context)
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decode(Int64.self, forKey: .identifier)
    name = try container.decode(String.self, forKey: .name)
    latitude = try container.decode(Double.self, forKey: .latitude)
    longitude = try container.decode(Double.self, forKey: .longitude)
    capacity = try container.decode(Int64.self, forKey: .capacity)
  }

  enum CodingKeys: String, CodingKey {
    case identifier = "id"
    case name
    case latitude
    case longitude
    case capacity
  }
}

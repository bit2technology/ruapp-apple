//
//  Dish.swift
//  RUappShared
//
//  Created by Igor Camilo on 13/12/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

import CoreData

@objc(Dish)
public final class Dish: NSManagedObject { }

extension Dish: NamedManagedObject {
  public static var entityName: String {
    return "Dish"
  }
}

extension Dish: Decodable {

  public convenience init(from decoder: Decoder) throws {
    let context = decoder.userInfo[.managedObjectContext] as! NSManagedObjectContext
    self.init(context: context)
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

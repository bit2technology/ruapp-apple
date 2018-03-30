//
//  NamedManagedObject.swift
//  RUappShared
//
//  Created by Igor Camilo on 27/03/18.
//  Copyright © 2018 Bit2 Technology. All rights reserved.
//

import CoreData

public protocol NamedManagedObject where Self: NSManagedObject {
  static var entityName: String { get }
}

extension NamedManagedObject {

  public init(context: NSManagedObjectContext) {
    self.init(entity: Self.entity(in: context), insertInto: context)
  }

  public static func entity(in context: NSManagedObjectContext) -> NSEntityDescription {
    return NSEntityDescription.entity(forEntityName: self.entityName, in: context)!
  }
}

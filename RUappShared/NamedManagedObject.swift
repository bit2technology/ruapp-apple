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

public extension NamedManagedObject {
  public init(context: NSManagedObjectContext) {
    let entity = NSEntityDescription.entity(forEntityName: Self.entityName, in: context)!
    self.init(entity: entity, insertInto: context)
  }
}

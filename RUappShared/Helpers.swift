//
//  RUappShared.swift
//  RUappShared
//
//  Created by Igor Camilo on 09/01/18.
//  Copyright © 2018 Bit2 Technology. All rights reserved.
//

import Foundation
import CoreData

extension Array {
  func orderedSet() -> NSOrderedSet {
    return NSOrderedSet(array: self)
  }
}

extension UserDefaults {
  public static let shared = UserDefaults(suiteName: "group.technology.bit2.ruapp")!
}

extension NSManagedObjectContext {
  public static var view: NSManagedObjectContext {
    return PersistentContainer.shared.viewContext
  }
}

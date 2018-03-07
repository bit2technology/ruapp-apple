//
//  RUappShared.swift
//  RUappShared
//
//  Created by Igor Camilo on 09/01/18.
//  Copyright © 2018 Bit2 Technology. All rights reserved.
//

import Foundation
import CoreData

public extension Array {
  func orderedSet() -> NSOrderedSet {
    return NSOrderedSet(array: self)
  }
}

public extension UserDefaults {
  public static let shared = UserDefaults(suiteName: "group.technology.bit2.ruapp")!
}

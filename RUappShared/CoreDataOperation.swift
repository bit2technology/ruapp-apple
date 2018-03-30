//
//  CoreDataOperation.swift
//  RUappShared
//
//  Created by Igor Camilo on 07/03/18.
//  Copyright © 2018 Bit2 Technology. All rights reserved.
//

import CoreData

open class CoreDataOperation: AsyncOperation<[NSManagedObjectID]> {

  public let context: NSManagedObjectContext?

  public init(context: NSManagedObjectContext?) {
    self.context = context
    super.init()
  }

  open override func main() {

    guard let context = context else {
      finish(error: CoreDataOperationError.noContext)
      return
    }

    context.perform {
      do {
        self.finish(try self.performInContextQueue(context: context))
      } catch {
        self.finish(error: error)
      }
    }
  }

  open func performInContextQueue(context: NSManagedObjectContext) throws -> [NSManagedObjectID] {
    return []
  }
}

public enum CoreDataOperationError: Error {
  case noContext
}

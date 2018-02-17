//
//  CoreDataOperation.swift
//  Bit2Common
//
//  Created by Igor Camilo on 29/11/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

import CoreData

open class CoreDataOperation: AdvancedOperation<[NSManagedObjectID]> {
    
    open var managedObjectContext: NSManagedObjectContext? {
        return nil
    }
    
    open override func main() {
        let context = managedObjectContext ?? CoreDataContainer.shared.newBackgroundContext()
        context.perform {
            do {
                let value = try self.backgroundTask(context: context)
                self.finish(value: value)
            } catch {
                self.finish(error: error)
            }
        }
    }
    
    /// Method to be implemented by subclasses. Runs in background.
    ///
    /// - Parameter context: A background context
    /// - Returns: A list of modified object IDs
    /// - Throws: Any error
    open func backgroundTask(context: NSManagedObjectContext) throws -> [NSManagedObjectID] {
        return []
    }
}

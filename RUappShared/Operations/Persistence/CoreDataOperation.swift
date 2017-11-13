//
//  CoreDataOperation.swift
//  RUappShared
//
//  Created by Igor Camilo on 07/11/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

import CoreData

public class CoreDataOperation: AsyncOperation<[NSManagedObjectID]> {
    
    public var managedObjectContext: NSManagedObjectContext? {
        return nil
    }
    
    public override func main() {
        let context = managedObjectContext ?? PersistentContainer.shared.newBackgroundContext()
        context.perform {
            do {
                let value = try self.backgroundTask(context: context)
                self.result = (value, nil)
            } catch {
                self.result = (nil, error)
            }
        }
    }
    
    /// Method to be implemented by subclasses. Runs in background.
    ///
    /// - Parameter context: A background context
    /// - Returns: A list of modified object IDs
    /// - Throws: Any error
    func backgroundTask(context: NSManagedObjectContext) throws -> [NSManagedObjectID]? {
        return nil
    }
}

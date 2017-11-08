//
//  CoreDataOperation.swift
//  RUappShared
//
//  Created by Igor Camilo on 07/11/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

import CoreData

open class CoreDataOperation: AsyncOperation<[NSManagedObjectID]> {
    
    open override func main() {
        PersistentContainer.shared.performBackgroundTask { (backgroundContext) in
            do {
                let value = try self.backgroundTask(context: backgroundContext)
                self.result = (value, nil)
            } catch {
                self.result = (nil, error)
            }
        }
    }
    
    open func backgroundTask(context: NSManagedObjectContext) throws -> [NSManagedObjectID]? {
        return nil
    }
}

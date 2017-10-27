//
//  PersistentContainer.swift
//  RUappShared
//
//  Created by Igor Camilo on 17/09/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

import CoreData
import PromiseKit

/// Core Data container
class PersistentContainer {
    
    let managedObjectModel: NSManagedObjectModel
    let persistentStoreCoordinator: NSPersistentStoreCoordinator
    let viewContext: NSManagedObjectContext
    
    /// Shared instance
    static let shared = try! PersistentContainer()
    
    /// Executes block in a background context
    ///
    /// - Parameter block: A block with the background context
    /// - Returns: A promise
    func background(_ block: @escaping (NSManagedObjectContext) throws -> Void) -> Promise<Void> {
        return Promise { (fulfill, reject) in
            
            // Create background context and execute
            let backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            backgroundContext.parent = viewContext
            backgroundContext.perform {
                do {
                    try block(backgroundContext)
                    guard self.viewContext.hasChanges else {
                        fulfill(())
                        return
                    }
                    
                    // Back to view context
                    self.viewContext.perform {
                        do {
                            try fulfill(self.viewContext.save())
                        } catch {
                            self.viewContext.rollback()
                            reject(error)
                        }
                    }
                } catch {
                    reject(error)
                }
            }
        }
    }
    
    init() throws {
        
        // Model
        let modelURL = Bundle(for: PersistentContainer.self).url(forResource: "Model", withExtension: "momd")!
        managedObjectModel = NSManagedObjectModel(contentsOf: modelURL)!
        
        // Coordinator
        persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        let databaseURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.technology.bit2.ruapp")!.appendingPathComponent("Data.sqlite")
        try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: databaseURL, options: nil)
        
        // Contexts
        viewContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        viewContext.persistentStoreCoordinator = persistentStoreCoordinator
        viewContext.undoManager = UndoManager()
    }
}

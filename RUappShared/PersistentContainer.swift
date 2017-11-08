//
//  PersistentContainer.swift
//  RUappShared
//
//  Created by Igor Camilo on 17/09/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

import CoreData

/// Core Data container
class PersistentContainer {
    
    let managedObjectModel: NSManagedObjectModel
    let persistentStoreCoordinator: NSPersistentStoreCoordinator
    let viewContext: NSManagedObjectContext
    
    /// Shared instance
    static let shared = try! PersistentContainer()
    
    func newBackgroundContext() -> NSManagedObjectContext {
        let backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        backgroundContext.parent = viewContext
        return backgroundContext
    }
    
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        let backgroundContext = newBackgroundContext()
        backgroundContext.perform {
            block(backgroundContext)
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

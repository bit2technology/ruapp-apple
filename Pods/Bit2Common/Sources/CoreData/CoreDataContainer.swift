//
//  CoreDataContainer.swift
//  Bit2Common
//
//  Created by Igor Camilo on 29/11/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

import CoreData

/// Core Data container
public class CoreDataContainer {
    
    public let managedObjectModel: NSManagedObjectModel
    public let persistentStoreCoordinator: NSPersistentStoreCoordinator
    public let viewContext: NSManagedObjectContext
    
    public static let shared = CoreDataContainer()
    public static var configuration: (bundle: Bundle, groupID: String?)?
    
    public func newBackgroundContext() -> NSManagedObjectContext {
        let backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        backgroundContext.parent = viewContext
        return backgroundContext
    }
    
    public func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        let backgroundContext = newBackgroundContext()
        backgroundContext.perform {
            block(backgroundContext)
        }
    }
    
    private init() {
        
        guard let configuration = CoreDataContainer.configuration else {
            preconditionFailure("CoreDataContainer.configuration must be set before usage.")
        }
        
        // Model
        managedObjectModel = NSManagedObjectModel.mergedModel(from: [configuration.bundle])!
        
        // Coordinator
        persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        let databaseDirectoryURL: URL
        if let groupID = configuration.groupID {
            databaseDirectoryURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupID)!
        } else {
            databaseDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        }
        try! persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: databaseDirectoryURL.appendingPathComponent("Data.sqlite"), options: nil)
        
        // Main context
        viewContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        viewContext.persistentStoreCoordinator = persistentStoreCoordinator
        viewContext.undoManager = UndoManager()
    }
}

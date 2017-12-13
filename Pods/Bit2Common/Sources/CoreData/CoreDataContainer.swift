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
    @available(*, deprecated, message: "Use 'options' instead")
    public static var configuration: (bundle: Bundle, groupID: String?)?
    public static var options: Options?
    
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
        
        guard let options = CoreDataContainer.options ?? Options(from: CoreDataContainer.configuration) else {
            preconditionFailure("CoreDataContainer.options must be set before usage.")
        }
        
        // Model
        managedObjectModel = NSManagedObjectModel.mergedModel(from: [options.bundle])!
        
        // Coordinator
        persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        let databaseDirectoryURL: URL
        if let groupID = options.groupID {
            databaseDirectoryURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupID)!
        } else {
            databaseDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        }
        try! persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: databaseDirectoryURL.appendingPathComponent("Data.sqlite"), options: options.automaticMigration ? [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true] : nil)
        
        // Main context
        viewContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        viewContext.persistentStoreCoordinator = persistentStoreCoordinator
        viewContext.undoManager = UndoManager()
    }
    
    public struct Options {
        public var automaticMigration: Bool
        public var bundle: Bundle
        public var groupID: String?
        
        public init(automaticMigration: Bool = false, bundle: Bundle, groupID: String? = nil) {
            self.automaticMigration = automaticMigration
            self.bundle = bundle
            self.groupID = groupID
        }
        
        fileprivate init?(from configuration: (bundle: Bundle, groupID: String?)?) {
            guard let configuration = configuration else {
                return nil
            }
            automaticMigration = false
            bundle = configuration.bundle
            groupID = configuration.groupID
        }
    }
}

//
//  PersistentContainer.swift
//  RUappShared
//
//  Created by Igor Camilo on 17/09/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

import CoreData

public class PersistentContainer {
    
    public let managedObjectModel: NSManagedObjectModel
    public let persistentStoreCoordinator: NSPersistentStoreCoordinator
    public let viewContext: NSManagedObjectContext
    
    public static let shared = try! PersistentContainer()
    
    public init(directoryURL: URL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.technology.bit2.ruapp")!) throws {
        
        // Model
        let modelURL = Bundle(for: PersistentContainer.self).url(forResource: "Model", withExtension: "momd")!
        managedObjectModel = NSManagedObjectModel(contentsOf: modelURL)!
        
        // Coordinator
        persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        let databaseURL = directoryURL.appendingPathComponent("Data.sqlite")
        try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: databaseURL, options: nil)
        
        // Contexts
        viewContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        viewContext.persistentStoreCoordinator = persistentStoreCoordinator
        viewContext.undoManager = UndoManager()
    }
}

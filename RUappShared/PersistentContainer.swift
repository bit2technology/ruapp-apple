//
//  PersistentContainer.swift
//  RUappShared
//
//  Created by Igor Camilo on 17/02/18.
//  Copyright © 2018 Bit2 Technology. All rights reserved.
//

import CoreData

public class PersistentContainer {

    public let model: NSManagedObjectModel
    public let coordinator: NSPersistentStoreCoordinator
    public let viewContext: NSManagedObjectContext
    public let url: URL

    public required init(model: NSManagedObjectModel, at url: URL) {
        self.model = model
        self.url = url
        coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        viewContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        viewContext.persistentStoreCoordinator = coordinator
    }

    public func loadPersistentStores(completionHandler block: @escaping (Error?) -> ()) {
        DispatchQueue.global().async {
            do {
                try self.coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: self.url)
                block(nil)
            } catch {
                block(error)
            }
        }
    }

    public func newBackgroundContext() -> NSManagedObjectContext {
        let backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        backgroundContext.parent = viewContext
        return backgroundContext
    }

    public func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> ()) {
        let backgroundContext = newBackgroundContext()
        backgroundContext.perform {
            block(backgroundContext)
        }
    }
}

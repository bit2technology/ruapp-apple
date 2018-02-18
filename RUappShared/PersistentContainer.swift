//
//  PersistentContainer.swift
//  RUappShared
//
//  Created by Igor Camilo on 17/02/18.
//  Copyright © 2018 Bit2 Technology. All rights reserved.
//

import CoreData

public protocol PersistentContainerProtocol {
    
    var viewContext: NSManagedObjectContext { get }
    
    static func create(model: NSManagedObjectModel, at url: URL) -> Self
    
    func loadPersistentStores(completionHandler block: @escaping (Error?) -> ())
    func newBackgroundContext() -> NSManagedObjectContext
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> ())
}

public class PersistentContainer {
    
    public let model: NSManagedObjectModel
    public let coordinator: NSPersistentStoreCoordinator
    public let viewContext: NSManagedObjectContext
    
    private let url: URL
    
    public required init(model: NSManagedObjectModel, at url: URL) {
        self.model = model
        self.url = url
        coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        viewContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        viewContext.persistentStoreCoordinator = coordinator
    }
}

extension PersistentContainer: PersistentContainerProtocol {
    
    public static func create(model: NSManagedObjectModel, at url: URL) -> Self {
        return self.init(model: model, at: url)
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

@available(iOSApplicationExtension 10.0, *)
extension NSPersistentContainer: PersistentContainerProtocol {
    
    public static func create(model: NSManagedObjectModel, at url: URL) -> Self {
        let container = self.init(name: "", managedObjectModel: model)
        let storeDescription = NSPersistentStoreDescription()
        storeDescription.url = url
        storeDescription.type = NSSQLiteStoreType
        container.persistentStoreDescriptions = [storeDescription]
        return container
    }
    
    public func loadPersistentStores(completionHandler block: @escaping (Error?) -> ()) {
        loadPersistentStores { (_, error) in
            block(error)
        }
    }
}

//
//  PersistentContainer.swift
//  RUappShared
//
//  Created by Igor Camilo on 17/02/18.
//  Copyright © 2018 Bit2 Technology. All rights reserved.
//

import CoreData

public class PersistentContainer {

  public static let shared: PersistentContainer = {
    let modelURL = Bundle(for: PersistentContainer.self).url(forResource: "Model", withExtension: "momd")!
    let model = NSManagedObjectModel(contentsOf: modelURL)!
    let dbURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.ruapp.bit2.technology")!
    return PersistentContainer(model: model, at: dbURL)
  }()

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

  public func loadPersistentStores(completionHandler block: @escaping (Error?) -> Void) {
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

  public func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
    let backgroundContext = newBackgroundContext()
    backgroundContext.perform {
      block(backgroundContext)
    }
  }
}

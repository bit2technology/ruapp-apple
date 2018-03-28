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
  public var storeDescriptions: [(type: String, url: URL?)] = []

  public init(model: NSManagedObjectModel) {
    self.model = model
    coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
    viewContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    viewContext.persistentStoreCoordinator = coordinator
  }

  public func loadPersistentStores(completionHandler block: @escaping (Error?) -> Void) {
    DispatchQueue.global().async {
      self.storeDescriptions.forEach {
        do {
          try self.coordinator.addPersistentStore(ofType: $0.type,
                                                  configurationName: nil,
                                                  at: $0.url)
          block(nil)
        } catch {
          block(error)
        }
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

public extension PersistentContainer {
  public internal(set) static var shared: PersistentContainer = {
    let modelURL = Bundle(for: PersistentContainer.self)
      .url(forResource: "Model", withExtension: "momd")!
    let model = NSManagedObjectModel(contentsOf: modelURL)!
    let dbURL = FileManager.default
      .containerURL(forSecurityApplicationGroupIdentifier: "group.technology.bit2.ruapp")!
      .appendingPathComponent("data.sqlite")
    let container = PersistentContainer(model: model)
    container.storeDescriptions = [(NSSQLiteStoreType, dbURL)]
    return container
  }()
}

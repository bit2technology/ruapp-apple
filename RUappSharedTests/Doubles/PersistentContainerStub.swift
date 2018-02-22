//
//  PersistentContainerStub.swift
//  RUappSharedTests
//
//  Created by Igor Camilo on 18/02/18.
//  Copyright © 2018 Bit2 Technology. All rights reserved.
//

import CoreData
import RUappShared

class PersistentContainerStub {

    let model: NSManagedObjectModel
    let coordinator: NSPersistentStoreCoordinator
    let viewContext: NSManagedObjectContext

    init() {
        model = NSManagedObjectModel(contentsOf: Bundle(for: Student.self).url(forResource: "Model", withExtension: "momd")!)!
        coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        do {
            try coordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
        } catch {
            fatalError(error.localizedDescription)
        }
        viewContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        viewContext.persistentStoreCoordinator = coordinator
    }
}

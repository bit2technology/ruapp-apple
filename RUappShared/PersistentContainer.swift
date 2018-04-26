//
//  PersistentContainer.swift
//  RUappShared
//
//  Created by Igor Camilo on 23/04/18.
//  Copyright © 2018 Bit2 Technology. All rights reserved.
//

import CoreData

public class PersistentContainer: NSPersistentContainer {

    public static let shared: NSPersistentContainer = {
        let storeDescription = NSPersistentStoreDescription(url: FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.technology.bit2.ruapp")!)
        storeDescription.type = NSSQLiteStoreType
        return PersistentContainer(persistentStoreDescriptions: [storeDescription])
    }()

    public init(persistentStoreDescriptions: [NSPersistentStoreDescription]) {
        let bundle = Bundle(for: PersistentContainer.self)
        let modelURL = bundle.url(forResource: "Model", withExtension: "momd")!
        let model = NSManagedObjectModel(contentsOf: modelURL)!
        super.init(name: "Model", managedObjectModel: model)
        self.persistentStoreDescriptions = persistentStoreDescriptions
        viewContext.automaticallyMergesChangesFromParent = true
    }
}

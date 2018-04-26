//
//  PersistentContainer.swift
//  RUappSharedTests
//
//  Created by Igor Camilo on 25/04/18.
//  Copyright © 2018 Bit2 Technology. All rights reserved.
//

import RUappShared
import CoreData

extension PersistentContainer {
    static func newInMemoryContainer() -> PersistentContainer {
        let storeDescription = NSPersistentStoreDescription(url: URL(string: "/dev/null")!)
        storeDescription.type = NSInMemoryStoreType
        return PersistentContainer(persistentStoreDescriptions: [storeDescription])
    }
}

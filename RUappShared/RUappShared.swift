//
//  RUappShared.swift
//  RUappShared
//
//  Created by Igor Camilo on 09/01/18.
//  Copyright © 2018 Bit2 Technology. All rights reserved.
//

import Bit2Common

public class RUappShared {
    public static func configure() {
        CoreDataContainer.options = CoreDataContainer.Options(automaticMigration: true, bundle: Bundle(for: RUappShared.self), groupID: "group.technology.bit2.ruapp")
    }
}

public extension OperationQueue {
    static let async: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "AsyncOperationQueue"
        return queue
    }()
}

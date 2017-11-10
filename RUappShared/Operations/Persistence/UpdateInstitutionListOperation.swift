//
//  UpdateInstitutionListOperation.swift
//  RUappShared
//
//  Created by Igor Camilo on 07/11/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

import CoreData

/// Downloads `Institution` List and adds to `PersistentContainer.viewContext`.
///
/// - Attention: `PersistentContainer.viewContext` not saved in this operation.
public class UpdateInstitutionListOperation: CoreDataOperation {
    
    private let instListOp = GetInstitutionListOperation()
    
    override var dependenciesToAdd: [Operation] {
        return [instListOp]
    }
    
    override func backgroundTask(context: NSManagedObjectContext) throws -> [NSManagedObjectID]? {
        let list: [Institution] = try instListOp.parse().map {
            try Institution.createOrUpdate(json: $0, context: context)
        }
        try context.save()
        return list.map { $0.objectID }
    }
    
    /// Get `Institution` list on `PersistentContainer.viewContext`.
    ///
    /// - Returns: `Institution` list
    /// - Throws: Any error
    public func parse() throws -> [Institution] {
        let context = PersistentContainer.shared.viewContext
        return try value().map { context.object(with: $0) as! Institution }
    }
}

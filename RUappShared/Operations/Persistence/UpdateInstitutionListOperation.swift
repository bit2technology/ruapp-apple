//
//  UpdateInstitutionListOperation.swift
//  RUappShared
//
//  Created by Igor Camilo on 07/11/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

import CoreData

/// Downloads `Institution` List and adds to `Student.managedObjectContext`.
///
/// - Attention: `Student.managedObjectContext` not saved in this operation.
public class UpdateInstitutionListOperation: CoreDataOperation {
    
    private let instListOp = GetInstitutionListOperation()
    
    override var dependenciesToAdd: [Operation] {
        return [instListOp]
    }
    
    public override var managedObjectContext: NSManagedObjectContext? {
        let ctx = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        ctx.parent = Student.managedObjectContext
        return ctx
    }
    
    override func backgroundTask(context: NSManagedObjectContext) throws -> [NSManagedObjectID]? {
        let list: [Institution] = try instListOp.parse().map {
            try Institution.createOrUpdate(json: $0, context: context)
        }
        
        guard !isCancelled else {
            return nil
        }
        
        try context.save()
        return list.map { $0.objectID }
    }
    
    public func checkError() throws {
        _ = try value()
    }
}

//
//  UpdateInstitutionListOperation.swift
//  RUappShared
//
//  Created by Igor Camilo on 07/11/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

import Bit2Common
import CoreData

public class UpdateInstitutionListOperation: CoreDataOperation {
    
    private let getOp = URLSessionDataTaskOperation(request: URLRoute.getInstitutions.urlRequest)
    
    public override init() {
        super.init()
        addDependency(getOp)
        OperationQueue.async.addOperation(getOp)
    }
    
    public override var managedObjectContext: NSManagedObjectContext? {
        let ctx = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        ctx.parent = Student.managedObjectContext
        return ctx
    }
    
    override public func backgroundTask(context: NSManagedObjectContext) throws -> [NSManagedObjectID] {
        
        let list = try JSONDecoder().decode([JSON.Institution].self, from: getOp.value()).map {
            try Institution.createOrUpdate(with: $0, context: context)
        }
        
        guard !isCancelled else {
            return []
        }
        
        try context.save()
        return list.map { $0.objectID }
    }
}

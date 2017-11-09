//
//  UpdateInstitutionListOperation.swift
//  RUappShared
//
//  Created by Igor Camilo on 07/11/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

import CoreData

public class UpdateInstitutionListOperation: CoreDataOperation {
    
    private let getInstitutionListOperation = GetInstitutionListOperation()
    
    public override var dependenciesToAdd: [Operation] {
        return [getInstitutionListOperation]
    }
    
    public override func backgroundTask(context: NSManagedObjectContext) throws -> [NSManagedObjectID]? {
        let list: [Institution] = try getInstitutionListOperation.parse().map {
            try Institution.createOrUpdate(json: $0, context: context)
        }
        try context.save()
        return list.map { $0.objectID }
    }
    
    public func parse() throws -> [Institution] {
        let context = PersistentContainer.shared.viewContext
        return try value().map { context.object(with: $0) as! Institution }
    }
}

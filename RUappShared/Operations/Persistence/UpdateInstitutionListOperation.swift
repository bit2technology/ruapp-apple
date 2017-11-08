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
            let fetchRequest: NSFetchRequest<Institution> = Institution.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id = %lld", Int64($0.id)!)
            fetchRequest.fetchLimit = 1
            if let institution = (try context.fetch(fetchRequest)).first {
                return institution.update(from: $0)
            } else {
                return Institution.new(with: context).update(from: $0)
            }
        }
        try context.save()
        try context.parent!.save()
        return list.map { $0.objectID }
    }
    
    public func parse() throws -> [Institution] {
        let context = PersistentContainer.shared.viewContext
        return try value().map { context.object(with: $0) as! Institution }
    }
}

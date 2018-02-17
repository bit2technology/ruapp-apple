//
//  AdvancedManagedObject.swift
//  Bit2Common
//
//  Created by Igor Camilo on 13/12/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

import CoreData

public protocol AdvancedManagedObjectRawTypeProtocol {
    associatedtype IDType
    var advancedID: IDType { get }
}

public protocol AdvancedManagedObjectProtocol where Self: NSManagedObject {
    associatedtype IDType where IDType == RawType.IDType
    associatedtype RawType: AdvancedManagedObjectRawTypeProtocol
    static var entityName: String { get }
    static func uniquePredicate(withID id: IDType) -> NSPredicate
    func update(with raw: RawType) throws
}

public extension AdvancedManagedObjectProtocol {
    
    var isSaved: Bool {
        return !objectID.isTemporaryID
    }
    
    static func new(with context: NSManagedObjectContext) -> Self {
        return NSEntityDescription.insertNewObject(forEntityName: entityName, into: context) as! Self
    }
    
    static func get(id: IDType, context: NSManagedObjectContext) throws -> Self? {
        let req = request()
        req.predicate = uniquePredicate(withID: id)
        req.fetchLimit = 1
        return (try context.fetch(req)).first
    }
    
    static func createOrUpdate(with raw: RawType, context: NSManagedObjectContext) throws -> Self {
        let obj = try get(id: raw.advancedID, context: context) ?? new(with: context)
        try obj.update(with: raw)
        return obj
    }
    
    static func request() -> NSFetchRequest<Self> {
        return NSFetchRequest<Self>(entityName: entityName)
    }
}

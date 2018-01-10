//
//  UpdateMenuOperation.swift
//  RUappShared
//
//  Created by Igor Camilo on 12/11/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

import Bit2Common
import CoreData

public class UpdateMenuOperation: CoreDataOperation {
    
    private let getOp: URLSessionDataTaskOperation
    
    public init(restaurantId: Int64) {
        getOp = URLSessionDataTaskOperation(request: URLRoute.menu(restaurantId: restaurantId).urlRequest)
        super.init()
        addDependency(getOp)
        OperationQueue.async.addOperation(getOp)
    }
    
    override public func backgroundTask(context: NSManagedObjectContext) throws -> [NSManagedObjectID] {
        
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        decoder.dateDecodingStrategy = .formatted(formatter)
        let mealIDs = try decoder.decode([JSON.Meal].self, from: getOp.value()).map { try Meal.createOrUpdate(with: $0, context: context).objectID }
        
        guard !isCancelled else {
            return []
        }
        
        try context.save()
        return mealIDs
    }
}

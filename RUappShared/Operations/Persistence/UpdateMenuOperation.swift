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
    
    private let getMenuOp: GetMenuOperation
    
    override public var dependenciesToAdd: [Operation] {
        return [getMenuOp]
    }
    
    override public func backgroundTask(context: NSManagedObjectContext) throws -> [NSManagedObjectID] {
        let meals = try getMenuOp.parse().map { (menu) -> [Meal] in
            var dayMeals = [Meal]()
            for (idx, meal) in menu.meals.enumerated() {
                guard meal.meta != "-" else {
                    continue
                }
                try dayMeals.append(Meal.createOrUpdate(json: meal, date: menu.date, index: Int64(idx), context: context))
            }
            return dayMeals
        }
        
        guard !isCancelled else {
            return []
        }
        
        try context.save()
        try context.parent!.save()
        return meals.flatMap { $0.map { $0.objectID } }
    }
    
    public init(restaurantId: Int64) {
        getMenuOp = GetMenuOperation(restaurantId: restaurantId)
        super.init()
    }
    
    public func parse() throws -> [Meal] {
        let context = CoreDataContainer.shared.viewContext
        return try value().map { context.object(with: $0) as! Meal }
    }
}

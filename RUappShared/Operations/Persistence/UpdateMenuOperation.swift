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
        
        // Get JSON and transform in [[Meal.ParsedRaw]], already filtering empty Meals.
        let parsedMeals = try getMenuOp.parse().map { (menu) -> [Meal.ParsedRaw] in
            return menu.meals.flatMap { Meal.ParsedRaw(from: $0, date: menu.date) }
        }
        // Get [[Meal.ParsedRaw]] and transform in [Meal], alread adding them to the context.
        let mealIDs = try parsedMeals.flatMap { try $0.map { try Meal.createOrUpdate(with: $0, context: context).objectID } }
        
        guard !isCancelled else {
            return []
        }
        
        try context.save()
        try context.parent!.save()
        return mealIDs
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

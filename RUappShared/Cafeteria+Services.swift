//
//  Cafeteria+Services.swift
//  RUappShared-iOS
//
//  Created by Igor Camilo on 20/03/18.
//  Copyright © 2018 Bit2 Technology. All rights reserved.
//

import CoreData

extension Cafeteria {

  public class func `default`(from userDefaults: UserDefaults = .shared,
                              in context: NSManagedObjectContext = .view) -> Cafeteria? {
    guard let cafeteriaID = userDefaults.value(forKey: "DefaultCafeteriaID") as? Int64 else {
      return nil
    }
    let request: NSFetchRequest<Cafeteria> = fetchRequest()
    request.fetchLimit = 1
    request.predicate = NSPredicate(format: "id = %lld", cafeteriaID)
    let result = try? context.fetch(request)
    return result?.first
  }

  public func setDefault(at userDefaults: UserDefaults = .shared) {
    userDefaults.set(id, forKey: "DefaultCafeteriaID")
  }

  public func nextMeal(for date: Date = Date(),
                       in context: NSManagedObjectContext = .view) -> Meal? {
    let request: NSFetchRequest<Meal> = Meal.fetchRequest()
    request.predicate = NSPredicate(format: "cafeteria = %@ AND close > %@",
                                    self,
                                    date as NSDate)
    request.sortDescriptors = [NSSortDescriptor(key: "close", ascending: true)]
    request.fetchLimit = 1
    let result = try? context.fetch(request)
    return result?.first
  }

  public func mealsFetchRequest(dateRange: DateRange) -> NSFetchRequest<Meal> {
    return Meal.fetchRequest(dateRange: dateRange, cafeteria: self)
  }
}

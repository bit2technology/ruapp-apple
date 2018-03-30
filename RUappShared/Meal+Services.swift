//
//  Meal+Services.swift
//  RUappShared-iOS
//
//  Created by Igor Camilo on 28/03/18.
//  Copyright © 2018 Bit2 Technology. All rights reserved.
//

import CoreData

extension Meal {
  public class func fetchRequest(dateRange: DateRange,
                                 cafeteria: Cafeteria) -> NSFetchRequest<Meal> {
    let request: NSFetchRequest<Meal> = fetchRequest()
    request.predicate = NSPredicate(
      format: "open < %@ AND close >= %@ AND cafeteria = %@",
      dateRange.upperBound as NSDate,
      dateRange.lowerBound as NSDate,
      cafeteria)
    return request
  }
}

//
//  UpdateMenuOperation.swift
//  RUappShared
//
//  Created by Igor Camilo on 12/11/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

import CoreData

public class UpdateMenuOperation: CoreDataOperation {

  public let cafeteria: Cafeteria

  let dataOp: URLSessionDataTaskOperation
  public override var dependenciesToAdd: [Operation] {
    return [dataOp]
  }

  public convenience init(cafeteria: Cafeteria) {
    let dataOp = URLSessionDataTaskOperation(request: URLRoute.menu(cafeteriaId: cafeteria.id).urlRequest)
    self.init(cafeteria: cafeteria, dataOp: dataOp)
  }

  init(cafeteria: Cafeteria, dataOp: URLSessionDataTaskOperation) {
    self.cafeteria = cafeteria
    self.dataOp = dataOp
    super.init(context: cafeteria.managedObjectContext)
  }

  public override func performInContextQueue(context: NSManagedObjectContext) throws -> [NSManagedObjectID] {

    let decoder = JSONDecoder.persistent(context: context)
    if #available(iOSApplicationExtension 10.0, *) {
      decoder.dateDecodingStrategy = .iso8601
    } else {
      let formatter = DateFormatter()
      formatter.locale = Locale(identifier: "en_US_POSIX")
      formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
      decoder.dateDecodingStrategy = .formatted(formatter)
    }
    
    let menu = try decoder.decode([Meal].self, from: dataOp.result())
    cafeteria.menu = NSSet(array: menu)
    try context.save()
    return menu.map { $0.objectID }
  }
}

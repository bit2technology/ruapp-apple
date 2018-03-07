//
//  UpdateInstitutionListOperation.swift
//  RUappShared
//
//  Created by Igor Camilo on 07/11/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

import CoreData

public class UpdateInstitutionListOperation: CoreDataOperation {

  let dataOp: URLSessionDataTaskOperation
  public override var dependenciesToAdd: [Operation] {
    return [dataOp]
  }

  public convenience init(context: NSManagedObjectContext) {
    self.init(context: context, dataOp: URLSessionDataTaskOperation(request: URLRoute.getInstitutions.urlRequest))
  }

  init(context: NSManagedObjectContext, dataOp: URLSessionDataTaskOperation) {
    self.dataOp = dataOp
    super.init(context: context)
  }

  public override func performInContextQueue(context: NSManagedObjectContext) throws -> [NSManagedObjectID] {
    let decoder = JSONDecoder.persistent(context: context)
    let list = try decoder.decode([Institution].self, from: dataOp.result())
    try context.save()
    return list.map { $0.objectID }
  }
}

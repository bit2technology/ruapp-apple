//
//  UpdateInstitutionListOperation.swift
//  RUappShared
//
//  Created by Igor Camilo on 07/11/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

import CoreData

public class UpdateInstitutionListOperation: AsyncOperation {

  public let context: NSManagedObjectContext

  let dataOp: URLSessionDataTaskOperation

  public convenience init(context: NSManagedObjectContext) {
    self.init(context: context, dataOp: URLSessionDataTaskOperation(request: URLRoute.getInstitutions.urlRequest))
  }

  init(context: NSManagedObjectContext, dataOp: URLSessionDataTaskOperation) {
    self.context = context
    self.dataOp = dataOp
    super.init()
    addDependency(dataOp)
    OperationQueue.async.addOperation(dataOp)
  }

  public override func main() {
    context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    context.perform {
      do {
        let decoder = JSONDecoder.persistent(context: self.context)
        _ = try decoder.decode([Institution].self, from: self.dataOp.data())

        guard !self.isCancelled else {
          return
        }

        try self.context.save()
        self.finish()
      } catch {
        self.finish(error: error)
      }
    }
  }
}

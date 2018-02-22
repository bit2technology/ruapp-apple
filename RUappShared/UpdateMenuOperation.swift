//
//  UpdateMenuOperation.swift
//  RUappShared
//
//  Created by Igor Camilo on 12/11/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

import CoreData

public class UpdateMenuOperation: AsyncOperation {

    public let cafeteria: Cafeteria

    let dataOp: URLSessionDataTaskOperation

    public convenience init(cafeteria: Cafeteria) {
        self.init(cafeteria: cafeteria, dataOp: URLSessionDataTaskOperation(request: URLRoute.menu(cafeteriaId: cafeteria.id).urlRequest))
    }

    init(cafeteria: Cafeteria, dataOp: URLSessionDataTaskOperation) {
        self.cafeteria = cafeteria
        self.dataOp = dataOp
        super.init()
        addDependency(dataOp)
        OperationQueue.async.addOperation(dataOp)
    }

    public override func main() {

        guard let context = cafeteria.managedObjectContext else {
            finish(error: UpdateMenuOperationError.noManagedObjectContext)
            return
        }

        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        context.perform {
            do {
                let decoder = JSONDecoder.persistent(context: context)
                if #available(iOSApplicationExtension 10.0, *) {
                    decoder.dateDecodingStrategy = .iso8601
                } else {
                    let formatter = DateFormatter()
                    formatter.locale = Locale(identifier: "en_US_POSIX")
                    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
                    decoder.dateDecodingStrategy = .formatted(formatter)
                }
                let meals = try decoder.decode([Meal].self, from: self.dataOp.data())
                self.cafeteria.menu = NSSet(array: meals)

                guard !self.isCancelled else {
                    return
                }

                try context.save()
                self.finish()
            } catch {
                self.finish(error: error)
            }
        }
    }
}

public enum UpdateMenuOperationError: Error {
    case noManagedObjectContext
}

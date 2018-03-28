//
//  Student+Services.swift
//  RUappShared-iOS
//
//  Created by Igor Camilo on 20/03/18.
//  Copyright © 2018 Bit2 Technology. All rights reserved.
//

import CoreData

extension Student {

  public class func `default`(from userDefaults: UserDefaults = .shared,
                              in context: NSManagedObjectContext = .view) -> Student? {
    guard let studentID = userDefaults.value(forKey: "DefaultStudentID") as? Int64 else {
      return nil
    }
    let request: NSFetchRequest<Student> = fetchRequest()
    request.fetchLimit = 1
    request.predicate = NSPredicate(format: "id = %lld", studentID)
    let result = try? context.fetch(request)
    return result?.first
  }

  public func setDefault(at userDefaults: UserDefaults = .shared) {
    userDefaults.set(id, forKey: "DefaultStudentID")
  }
}

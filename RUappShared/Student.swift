//
//  Student.swift
//  RUappShared
//
//  Created by Igor Camilo on 13/09/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

import CoreData
import PromiseKit

@objc(Student)
public class Student: NSManagedObject, Codable {

  public class func `default`(from userDefaults: UserDefaults = .shared, in context: NSManagedObjectContext = PersistentContainer.shared.viewContext) -> Student? {
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

  public convenience init(context: NSManagedObjectContext) {
    self.init(entity: NSEntityDescription.entity(forEntityName: "Student", in: context)!, insertInto: context)
  }

  public override func validateForInsert() throws {
    try super.validateForInsert()
    try validateConsistency()
  }

  public override func validateForUpdate() throws {
    try super.validateForUpdate()
    try validateConsistency()
  }

  private func validateConsistency() throws {
    guard institution != nil else {
      throw StudentError.noInstitution
    }
  }

  // Codable

  public required convenience init(from decoder: Decoder) throws {
    let context = decoder.userInfo[.managedObjectContext] as! NSManagedObjectContext
    self.init(context: context)
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decode(Int64.self, forKey: .identifier)
    name = try container.decode(String.self, forKey: .name)
    numberPlate = try container.decode(String.self, forKey: .numberPlate)
    let institutionId = try container.decode(Int64.self, forKey: .institutionId)
    let request: NSFetchRequest<Institution> = Institution.fetchRequest()
    request.fetchLimit = 1
    request.predicate = NSPredicate(format: "id = %lld", institutionId)
    let result = try? context.fetch(request)
    institution = result?.first
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(name, forKey: .name)
    try container.encode(numberPlate, forKey: .numberPlate)
    try container.encode(institution?.id, forKey: .institutionId)
  }

  enum CodingKeys: String, CodingKey {
    case identifier = "id"
    case name
    case numberPlate = "number_plate"
    case institutionId = "institution_id"
  }
}

extension Student {

  public func save() -> Promise<Student> {
    do {
      let data = try JSONEncoder().encode(self)
      if objectID.isTemporaryID {
        return save(request: URLRoute.postStudent(data))
      } else {
        return save(request: URLRoute.patchStudent(id: id, data))
      }
    } catch {
      return Promise<Student>(error: error)
    }
  }

  func save(request: URLRequestConvertible) -> Promise<Student> {
    return URLSession.shared.dataTask(.promise, with: request)
      .then { (response) in
        self.managedObjectContext!.mergingObjects().performPromise {
          try response.response.validateHTTPStatusCode()
          let decoder = JSONDecoder.persistent(context: self.managedObjectContext!)
          let newStudent = try decoder.decode(Student.self, from: response.data)
          self.id = newStudent.id
          self.managedObjectContext!.delete(newStudent) // Delete duplicate
          try self.managedObjectContext!.save()
          return self
        }
    }
  }
}

public enum StudentError: Error {
  case noInstitution
}

//
//  SaveStudentOperation.swift
//  RUappShared
//
//  Created by Igor Camilo on 08/11/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

import CoreData

public class SaveStudentOperation: CoreDataOperation {

  public let student: Student

  let dataOp: URLSessionDataTaskOperation?
  public override var dependenciesToAdd: [Operation] {
    if let dataOp = dataOp {
      return [dataOp]
    } else {
      return []
    }
  }

  public convenience init(student: Student) {
    do {
      let studentOp: URLSessionDataTaskOperation
      let data = try JSONEncoder().encode(student)
      // Check if student is already in the database
      if student.objectID.isTemporaryID {
        // Save
        try student.validateForInsert()
        studentOp = URLSessionDataTaskOperation(request: URLRoute.postStudent(data).urlRequest)
      } else {
        // Update
        try student.validateForUpdate()
        studentOp = URLSessionDataTaskOperation(request: URLRoute.patchStudent(id: student.id, data).urlRequest)
      }
      self.init(student: student, dataOp: studentOp)
    } catch {
      self.init(student: student, dataOp: nil)
      finish(error: error)
    }
  }

  init(student: Student, dataOp: URLSessionDataTaskOperation?) {
    self.student = student
    self.dataOp = dataOp
    super.init(context: student.managedObjectContext)
  }

  public override func performInContextQueue(context: NSManagedObjectContext) throws -> [NSManagedObjectID] {
    let decoder = JSONDecoder.persistent(context: context)
    // This operation won't run if dataOp == nil anyway
    let newStudent = try decoder.decode(Student.self, from: dataOp!.result())
    student.id = newStudent.id
    context.delete(newStudent) // Delete duplicate
    try context.save()
    return [student.objectID]
  }
}

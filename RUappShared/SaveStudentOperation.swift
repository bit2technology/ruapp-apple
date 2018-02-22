//
//  SaveStudentOperation.swift
//  RUappShared
//
//  Created by Igor Camilo on 08/11/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

import CoreData

public class SaveStudentOperation: AsyncOperation {
    
    public let student: Student
    
    let studentOp: URLSessionDataTaskOperation?
    
    public convenience init(student: Student) {
        do {
            let studentOp: URLSessionDataTaskOperation?
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
            self.init(student: student, studentOp: studentOp)
        } catch {
            self.init(student: student, studentOp: nil)
            finish(error: error)
        }
    }
    
    init(student: Student, studentOp: URLSessionDataTaskOperation?) {
        self.student = student
        self.studentOp = studentOp
        super.init()
        if let studentOp = studentOp {
            addDependency(studentOp)
            OperationQueue.async.addOperation(studentOp)
        }
    }
    
    public override func main() {
        
        guard let context = student.managedObjectContext else {
            finish(error: SaveStudentOperationError.noManagedObjectContext)
            return
        }
        
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        context.perform {
            do {
                // Check if studentOp finished successfully, but discard data
                _ = try self.studentOp?.data()
                
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

public enum SaveStudentOperationError: Error {
    case noManagedObjectContext
}

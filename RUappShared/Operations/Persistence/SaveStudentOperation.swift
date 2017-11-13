//
//  SaveStudentOperation.swift
//  RUappShared
//
//  Created by Igor Camilo on 08/11/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

import CoreData

/// Register or edit `Student` in API and saves it on disk.
public class SaveStudentOperation: CoreDataOperation {
    
    /// Register or edit.
    private let kind: Kind
    
    init(values: JSON.Student?) {
        let student = Student.current
        
        // Finish operation if there is no JSON or if student is invalid
        guard let values = values, student.isValid else {
            kind = .none
            super.init()
            result = (nil, SaveStudentOperationError.invalidStudent)
            return
        }
        
        // Initialization
        if student.isSaved {
            // If institution changed, download new data
            let instOp: GetInstitutionOperation?
            if student.changedValues()["institution"] != nil {
                instOp = GetInstitutionOperation(id: student.id)
            } else {
                instOp = nil
            }
            kind = .edit(EditStudentOperation(studentId: student.id, values: values), instOp)
        } else {
            kind = .register(RegisterStudentOperation(student: values))
        }
        super.init()
    }
    
    override var dependenciesToAdd: [Operation] {
        switch kind {
        case .edit(let editOp, let instOp):
            if let instOp = instOp {
                return [editOp, instOp]
            } else {
                return [editOp]
            }
        case .register(let registerOp):
            return [registerOp]
        case .none:
            return []
        }
    }
    
    public override var managedObjectContext: NSManagedObjectContext? {
        return Student.managedObjectContext
    }
    
    override func backgroundTask(context: NSManagedObjectContext) throws -> [NSManagedObjectID]? {
        let student = context.object(with: Student.current.objectID) as! Student
        switch kind {
        case .none:
            return nil
        case .edit(let editOp, let instOp):
            guard try editOp.parse() else {
                throw SaveStudentOperationError.editUnsuccessful
            }
            if let institution = try instOp?.parse() {
                try student.institution?.update(from: institution)
            }
        case .register(let registerOp):
            student.id = try registerOp.parse().studentId
        }
        
        guard !isCancelled else {
            return nil
        }
        
        // Persist and return
        try context.save()
        try context.parent!.save()
        return [student.objectID]
    }
    
    /// Check save operation. If successful, this method returns nothing. Otherwise, throws an error.
    ///
    /// - Throws: `SaveStudentOperationError` and others
    public func checkError() throws {
        _ = try value()
    }
    
    private enum Kind {
        case edit(EditStudentOperation, GetInstitutionOperation?)
        case register(RegisterStudentOperation)
        case none
    }
}

public enum SaveStudentOperationError: Error {
    case invalidStudent
    case editUnsuccessful
}

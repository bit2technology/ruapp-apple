//
//  SaveStudentOperation.swift
//  RUappShared
//
//  Created by Igor Camilo on 08/11/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

import CoreData

public class SaveStudentOperation: CoreDataOperation {
    
    private let kind: Kind
    
    init(values: JSON.Student) {
        let student = Student.current
        if student.isSaved {
            let getInstitutionOperation: GetInstitutionOperation?
            if student.changedValues()["institution"] != nil {
                getInstitutionOperation = GetInstitutionOperation(id: student.id)
            } else {
                getInstitutionOperation = nil
            }
            kind = .edit(EditStudentOperation(studentId: student.id, values: values), getInstitutionOperation)
        } else {
            kind = .register(RegisterStudentOperation(student: values))
        }
        super.init()
        if !student.isValid {
            result = (nil, SaveStudentOperationError.invalidStudent)
        }
    }
    
    public override var dependenciesToAdd: [Operation] {
        switch kind {
        case .edit(let editStudentOperation, let getInstitutionOperation):
            if let getInstitutionOperation = getInstitutionOperation {
                return [editStudentOperation, getInstitutionOperation]
            } else {
                return [editStudentOperation]
            }
        case .register(let registerStudentOperation):
            return [registerStudentOperation]
        }
    }
    
    public override func backgroundTask(context: NSManagedObjectContext) throws -> [NSManagedObjectID]? {
        let student = context.object(with: Student.current.objectID) as! Student
        switch kind {
        case .edit(let editStudentOperation, let getInstitutionOperation):
            guard try editStudentOperation.parse() else {
                throw SaveStudentOperationError.editUnsuccessful
            }
            if let institution = try getInstitutionOperation?.parse() {
                try student.institution?.update(from: institution)
            }
        case .register(let registerStudentOperation):
            student.id = try registerStudentOperation.parse().studentId
        }
        try context.save()
        try context.parent!.save()
        return [student.objectID]
    }
    
    public func persist() throws {
        _ = try value()
    }
    
    private enum Kind {
        case edit(EditStudentOperation, GetInstitutionOperation?)
        case register(RegisterStudentOperation)
    }
}

public enum SaveStudentOperationError: Error {
    case invalidStudent
    case editUnsuccessful
}

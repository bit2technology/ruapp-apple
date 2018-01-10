//
//  Student.swift
//  RUappShared
//
//  Created by Igor Camilo on 13/09/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

import Bit2Common
import CoreData

extension Student {
    
    public var isSaved: Bool {
        return !objectID.isTemporaryID
    }
    
    public var isValid: Bool {
        return !(name?.isEmpty ?? true) && !(numberPlate?.isEmpty ?? true) && institution != nil
    }
    
    static func new(with context: NSManagedObjectContext) -> Student {
        return NSEntityDescription.insertNewObject(forEntityName: "Student", into: context) as! Student
    }
    
    public private(set) static var current: Student = {
        let request: NSFetchRequest<Student> = fetchRequest()
        request.fetchLimit = 1
        let result = try? managedObjectContext.fetch(request)
        return result?.first ?? Student.new(with: managedObjectContext)
    }()
    
    public static let managedObjectContext = CoreDataContainer.shared.newBackgroundContext()
    
    /*public func saveOperation() -> SaveStudentOperation {
        let json: JSON.Student?
        if let name = name, let numberPlate = numberPlate, let institution = institution {
            json = JSON.Student(name: name, numberPlate: numberPlate, institutionId: institution.id)
        } else {
            json = nil
        }
        return SaveStudentOperation(values: json)
    }*/
}

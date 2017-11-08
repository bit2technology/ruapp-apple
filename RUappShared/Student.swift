//
//  Student.swift
//  RUappShared
//
//  Created by Igor Camilo on 13/09/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

import PromiseKit
import CoreData

/// Send to cloud
extension Student {
    
    public func save() -> Promise<Void> {
        let json = JSON.Student(name: name!, numberPlate: numberPlate!, institutionId: String(institution!.id))
        if isInserted {
            fatalError("PromiseKit")
        } else {
            return request(URLRoute.register(student: json)).responseData().then {
                let context = PersistentContainer.shared.viewContext
                do {
                    let container = try JSONDecoder().decode(JSON.RegisteredStudent.self, from: $0)
                    _ = try Student.persistenceAdd(json: json, container: container, context: context)
                    return Promise(value: ())
                } catch {
                    context.rollback()
                    throw error
                }
            }
        }
    }
    
    // FIXME: Implement edit registered student
    /*public func save(completion: @escaping CompletionHandler<Void>) throws {
        let json = JSONStudent(name: name!, numberPlate: numberPlate!, institutionId: String(institution!.id))
        // Check if institution changed. If so, download new institution data and then update student on server
        if changedValues()["institution"] != nil {
            URLRoute.getInstitution(id: json.institutionId).request.response { (result) in
                do {
                    let institutionJSON = try JSONDecoder().decode(JSONInstitution.self, from: result())
                    URLRoute.edit(studentId: Int(self.id), values: json).request.response { (result) in
                        do {
                            guard String(data: try result(), encoding: .utf8) == "success" else {
                                throw StudentError.saveUnsuccessful
                            }
                            self.institution!.update(from: institutionJSON)
                            try self.managedObjectContext!.save()
                            completion {
                                return
                            }
                        } catch {
                            self.managedObjectContext!.rollback()
                            // Student error
                            completion {
                                throw error
                            }
                        }
                    }
                } catch {
                    self.managedObjectContext!.rollback()
                    // Institution error
                    completion {
                        throw error
                    }
                }
            }
        } else {
            URLRoute.edit(studentId: Int(self.id), values: json).request.response { (result) in
                do {
                    guard String(data: try result(), encoding: .utf8) == "success" else {
                        throw StudentError.saveUnsuccessful
                    }
                    try self.managedObjectContext!.save()
                    completion {
                        return
                    }
                } catch {
                    self.managedObjectContext!.rollback()
                    completion {
                        throw error
                    }
                }
            }
        }
    }*/
    
    static func persistenceAdd(json: JSON.Student, container: JSON.RegisteredStudent, context: NSManagedObjectContext) throws -> Student {
        let student = NSEntityDescription.insertNewObject(forEntityName: "Student", into: context) as! Student
        student.id = Int64(container.studentId)
        student.name = json.name
        student.numberPlate = json.numberPlate
        student.institution = Institution.new(with: context)
        student.institution?.update(from: container.institution)
//        student.defaultCafeteria = (student.institution?.campi?.anyObject() as? Campus)?.cafeterias?.anyObject() as? Cafeteria
        try context.save()
        return student
    }
}

extension Student {
    public static var shared: Student {
        let request: NSFetchRequest<Student> = fetchRequest()
        request.fetchLimit = 1
        let result = try? PersistentContainer.shared.viewContext.fetch(request)
        return result?.first ?? Student(entity: request.entity!, insertInto: nil)
    }
}

public enum StudentError: Error {
    case saveUnsuccessful
}

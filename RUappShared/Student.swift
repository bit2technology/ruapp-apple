//
//  Student.swift
//  RUappShared
//
//  Created by Igor Camilo on 13/09/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

import CoreData

extension Student {
    static var entityName: String {
        return "Student"
    }
}

/// Send to cloud
extension Student {
    
    public static func register(name: String, numberPlate: String, on institution: Institution.Overview, completion: @escaping CompletionHandler<(Student)>) {
        let json = JSONStudent(name: name, numberPlate: numberPlate, institutionId: String(institution.id))
        URLRouter.register(student: json).request.response { (result) in
            let context = PersistentContainer.shared.viewContext
            do {
                let container = try JSONDecoder().decode(JSONRegisteredStudent.self, from: result())
                let student = try Student.persistenceAdd(json: json, container: container, context: context)
                completion {
                    return student
                }
            } catch {
                context.rollback()
                completion {
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
            URLRouter.institution(id: json.institutionId).request.response { (result) in
                do {
                    let institutionJSON = try JSONDecoder().decode(JSONInstitution.self, from: result())
                    URLRouter.edit(studentId: Int(self.id), values: json).request.response { (result) in
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
            URLRouter.edit(studentId: Int(self.id), values: json).request.response { (result) in
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
    
    static func persistenceAdd(json: JSONStudent, container: JSONRegisteredStudent, context: NSManagedObjectContext) throws -> Student {
        let student = NSEntityDescription.insertNewObject(forEntityName: Student.entityName, into: context) as! Student
        student.id = Int64(container.studentId)
        student.name = json.name
        student.numberPlate = json.numberPlate
        student.institution = (NSEntityDescription.insertNewObject(forEntityName: Institution.entityName, into: context) as! Institution)
        student.institution?.update(from: container.institution)
        student.defaultCafeteria = (student.institution?.campi?.anyObject() as? Campus)?.cafeterias?.anyObject() as? Cafeteria
        try context.save()
        return student
    }
}

extension Student {
    public static var shared: Student? {
        let request: NSFetchRequest<Student> = fetchRequest()
        request.fetchLimit = 1
        return try! PersistentContainer.shared.viewContext.fetch(request).first
    }
}

public enum StudentError: Error {
    case saveUnsuccessful
}

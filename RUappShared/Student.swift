//
//  Student.swift
//  RUappShared
//
//  Created by Igor Camilo on 13/09/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

public final class Student {
    
    private var json: JSONStudent
    
    private convenience init() throws {
        self.init(json: try JSONDecoder().decode(JSONStudent.self, from: Data(contentsOf: Student.persistenceURL)))
    }
    
    private init(json: JSONStudent) {
        self.json = json
    }
    
    // MARK: Static
    
    public private(set) static var shared = try? Student()
    
    public static func register(name: String, numberPlate: String, completion: @escaping CompletionHandler<(Student, Institution)>) {
        var student = JSONStudent(id: nil, name: name, numberPlate: numberPlate, institutionId: defaultInstitutionId)
        URLRouter.register(student: student).request.response { (result) in
            do {
                let registeredStudent = try JSONDecoder().decode(JSONRegisteredStudent.self, from: result())
                student.id = registeredStudent.studentId
                try Student.localRegister(json: student)
                try Institution.localRegister(json: registeredStudent.institution)
                completion {
                    return (Student.shared!, Institution.shared!)
                }
            } catch {
                try? Student.unregister()
                try? Institution.unregister()
                completion {
                    throw error
                }
            }
        }
    }
    
    public static func unregister() throws {
        shared = nil
        try FileManager.default.removeItem(at: persistenceURL)
    }
    
    static func localRegister(json: JSONStudent) throws {
        try JSONEncoder().encode(json).write(to: persistenceURL)
        shared = Student(json: json)
    }
    
    private static var persistenceURL: URL {
        return sharedDirectoryURL().appendingPathComponent("student.json")
    }
}

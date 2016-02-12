//
//  Student.swift
//  RUapp
//
//  Created by Igor Camilo on 15-09-23.
//  Copyright © 2015 Igor Camilo. All rights reserved.
//

private let StudentSavedDictionaryKey = "SavedStudentDictionary"

public class Student {
    
    public let id: Int
    public let name: String
    public let studentId: String
    
    public private(set) static var shared = try? Student(dict: globalUserDefaults?.objectForKey(StudentSavedDictionaryKey))
    
    private init(dict: AnyObject?) throws {
        
        guard let dict = dict as? [String:AnyObject],
            dictId = dict["institution_id"] as? Int,
            dictName = dict["name"] as? String,
            dictStudent = dict["number_plate"] as? String else {
                throw Error.InvalidObject
        }
        
        id = dictId
        name = dictName
        studentId = dictStudent
    }
    
    class func register(dict: AnyObject?) throws -> Student? {
        shared = try Student(dict: dict)
        globalUserDefaults?.setObject(dict, forKey: StudentSavedDictionaryKey)
        return shared
    }
    
    class func register(id: Int, name: String, studentId: String) throws -> Student? {
        return try register(["name": name, "number_plate": studentId, "institution_id": id])
    }
}

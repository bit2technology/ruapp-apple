//
//  Student.swift
//  RUapp
//
//  Created by Igor Camilo on 15-09-23.
//  Copyright © 2015 Igor Camilo. All rights reserved.
//

private var globalStudent = try? Student(dict: globalUserDefaults?.objectForKey(StudentSavedDictionaryKey))
private let StudentSavedDictionaryKey = "SavedStudentDictionary"

public class Student {
    
    public let id: Int
    public let name: String
    public let studentId: String
    
    public class func shared() -> Student? {
        return globalStudent
    }
    
    private init(dict: AnyObject?) throws {
        do {
            guard let dict = dict as? [String:AnyObject],
                dictId = dict["id"] as? Int,
                dictName = dict["nome"] as? String,
                dictStudent = dict["matricula"] as? String else {
                    throw Error.InvalidObject
            }
            
            id = dictId
            name = dictName
            studentId = dictStudent
        }
        catch {
            id = -1
            name = ""
            studentId = ""
            throw error
        }
    }
    
    class func register(dict: AnyObject?) throws -> Student? {
        globalStudent = try Student(dict: dict)
        globalUserDefaults?.setObject(dict, forKey: StudentSavedDictionaryKey)
        return globalStudent
    }
}

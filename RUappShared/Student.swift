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
        
        guard FileManager.default.fileExists(atPath: Student.studentDataURL.path) else {
            throw StudentError.fileDoesNotExist
        }
        
        self.init(json: try JSONDecoder().decode(JSONStudent.self, from: Data(contentsOf: Student.studentDataURL)))
    }
    
    private init(json: JSONStudent) {
        self.json = json
    }
    
    // MARK: Static
    
    public private(set) static var shared = try? Student()
    
    private static var studentDataURL: URL {
        return sharedDirectoryURL().appendingPathComponent("student.json")
    }
}

public enum StudentError: Error {
    case fileDoesNotExist
}

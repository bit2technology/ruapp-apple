//
//  Student.swift
//  RUapp
//
//  Created by Igor Camilo on 15-09-23.
//  Copyright © 2015 Igor Camilo. All rights reserved.
//

import Alamofire

/// This class represents the current student registered on this device.
public final class Student {
    
    /// Shared instance.
    public private(set) static var shared = try? Student(dict: globalUserDefaults.objectForKey(savedDataKey))
    
    // Private keys
    private static let savedDataKey = "saved_student"
    private static let idKey = "student_id"
    private static let nameKey = "name"
    private static let numberPlateKey = "number_plate"
    
    /// Register a new student on the provided institution. This also saves both student and institution data on the device.
    public class func register(name name: String, numberPlate: String, on institution: Institution, completion: (result: Result<Student>) -> Void) {
        // Make request
        let req = NSMutableURLRequest(URL: NSURL(string: ServiceURL.registerStudent)!)
        req.HTTPMethod = "POST"
        let params = ["institution_id": institution.id, nameKey: name, numberPlateKey: numberPlate]
        req.HTTPBody = params.appPrepare()
        Alamofire.request(req).responseJSON { (response) in
            do {
                // Verify values
                guard response.result.isSuccess else {
                    throw response.result.error ?? Error.NoData
                }
                guard let jsonObj = response.result.value,
                    id = jsonObj[idKey] as? Int,
                    institutionDict = jsonObj["institution"] else {
                        throw Error.InvalidObject
                }
                // Save student
                let studentDict = [idKey: id, nameKey: name, numberPlateKey: numberPlate]
                let newStudent = try Student(dict: studentDict)
                shared = newStudent
                globalUserDefaults.setObject(studentDict, forKey: savedDataKey) // It will sync in next command
                try institution.update(institutionDict)
                completion(result: .Success(value: newStudent))
            } catch {
                // Erase all data from Student and Institution
                shared = nil
                globalUserDefaults.removeObjectForKey(savedDataKey) // It will sync in next command
                Institution.clear()
                completion(result: .Failure(error: error))
            }
        }
    }
    
    /// Initialization by plist.
    private init(dict: AnyObject?) throws {
        // Verify values
        guard let
            id = dict?[Student.idKey] as? Int,
            name = dict?[Student.nameKey] as? String,
            numberPlate = dict?[Student.numberPlateKey] as? String else {
                throw Error.InvalidObject
        }
        // Initialize proprieties
        self.id = id
        self.name = name
        self.numberPlate = numberPlate
    }
    
    // MARK: Instance
    
    /// API identification.
    public let id: Int
    /// Display name.
    public private(set) var name: String
    /// Identification on the current Institution.
    public private(set) var numberPlate: String
    
    /// Student errors.
    enum Error: ErrorType {
        case InvalidObject
        case NoData
    }
}

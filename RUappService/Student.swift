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
    private static let institutionKey = "institution"
    private static let institutionIdKey = "institution_id"
    
    /// Register a new student on the provided institution. This also saves both student and institution data on the device.
    public class func register(name name: String, numberPlate: String, on institution: Institution, completion: (student: Student?, error: ErrorType?) -> Void) {
        // Make request
        let req = NSMutableURLRequest(URL: NSURL(string: ServiceURL.registerStudent)!)
        req.HTTPMethod = "POST"
        let params = [institutionIdKey: institution.id, nameKey: name, numberPlateKey: numberPlate] as [String:AnyObject]
        req.HTTPBody = params.appPrepare()
        Alamofire.request(req).responseJSON { (response) in
            do {
                // Verify values
                guard response.result.isSuccess else {
                    throw response.result.error ?? Error.NoData
                }
                guard let jsonObj = response.result.value,
                    id = jsonObj[idKey] as? Int,
                    institutionDict = jsonObj[institutionKey] else {
                        throw Error.InvalidObject
                }
                // Save student
                shared = Student(id: id, name: name, numberPlate: numberPlate)
                let studentDict = [idKey: id, nameKey: name, numberPlate: numberPlate]
                globalUserDefaults.setObject(studentDict, forKey: savedDataKey) // It will sync in next command
                try institution.update(institutionDict)
                completion(student: shared, error: nil)
            } catch {
                // Erase all data from Student and Institution
                shared = nil
                globalUserDefaults.removeObjectForKey(savedDataKey)
                Institution.clear() // It will sync in next command
                completion(student: nil, error: error)
            }
        }
    }
    
    // MARK: Instance
    
    /// API identification.
    public let id: Int
    /// Display name.
    public private(set) var name: String
    /// Identification on the current Institution.
    public private(set) var numberPlate: String
    
    /// Initialization by values.
    private init(id: Int, name: String, numberPlate: String) {
        // Initialize proprieties
        self.id = id
        self.name = name
        self.numberPlate = numberPlate
    }
    
    /// Initialization by plist.
    private convenience init(dict: AnyObject?) throws {
        // Verify values
        guard let
            id = dict?[Student.idKey] as? Int,
            name = dict?[Student.nameKey] as? String,
            numberPlate = dict?[Student.numberPlateKey] as? String else {
                throw Error.InvalidObject
        }
        self.init(id: id, name: name, numberPlate: numberPlate)
    }
    
    /// Student errors.
    enum Error: ErrorType {
        case InvalidObject
        case NoData
    }
}

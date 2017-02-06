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
    
    fileprivate static func saved() throws -> [String : Any] {
        guard let saved = globalUserDefaults.object(forKey: savedDataKey) else {
            throw Error.noData
        }
        guard let savedDict = saved as? [String : Any] else {
            throw Error.invalidObject
        }
        return savedDict
    }
    
    /// Shared instance.
    public fileprivate(set) static var shared = try? Student(dict: saved())
    
    // Private keys
    fileprivate static let savedDataKey = "saved_student"
    fileprivate static let idKey = "student_id"
    fileprivate static let nameKey = "name"
    fileprivate static let numberPlateKey = "number_plate"
    
    /// Register a new student on the provided institution. This also saves both student and institution data on the device.
    public class func register(name: String, numberPlate: String, on institution: Institution, completion: @escaping (_ result: Result<Student>) -> Void) {
        // Make request
        var req = URLRequest(url: URL(string: ServiceURL.registerStudent)!)
        req.httpMethod = "POST"
        let params = ["institution_id": institution.id, nameKey: name, numberPlateKey: numberPlate] as [String : Any]
        req.httpBody = params.appPrepare()
        Alamofire.request(req).responseJSON { (response) in
            do {
                // Verify values
                guard response.result.isSuccess else {
                    throw response.result.error ?? Error.noData
                }
                guard let jsonObj = response.result.value as? [String : Any],
                    let id = jsonObj[idKey] as? Int,
                    let institutionDict = jsonObj["institution"] as? [String : Any] else {
                        throw Error.invalidObject
                }
                // Save student
                let studentDict = [idKey: id, nameKey: name, numberPlateKey: numberPlate] as [String : Any]
                let newStudent = try Student(dict: studentDict)
                shared = newStudent
                globalUserDefaults.set(studentDict, forKey: savedDataKey) // It will sync in next command
                try institution.update(institutionDict)
                completion(.success(value: newStudent))
            } catch {
                // Erase all data from Student and Institution
                shared = nil
                globalUserDefaults.removeObject(forKey: savedDataKey) // It will sync in next command
                Institution.clear()
                completion(.failure(error: error))
            }
        }
    }
    
    /// Initialization by plist.
    fileprivate init(dict: [String : Any]) throws {
        // Verify values
        guard let
            id = dict[Student.idKey] as? Int,
            let name = dict[Student.nameKey] as? String,
            let numberPlate = dict[Student.numberPlateKey] as? String else {
                throw Error.invalidObject
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
    public fileprivate(set) var name: String
    /// Identification on the current Institution.
    public fileprivate(set) var numberPlate: String
    
    /// Student errors.
    enum Error: Swift.Error {
        case invalidObject
        case noData
    }
}

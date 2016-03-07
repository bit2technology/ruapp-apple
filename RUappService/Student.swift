//
//  Student.swift
//  RUapp
//
//  Created by Igor Camilo on 15-09-23.
//  Copyright © 2015 Igor Camilo. All rights reserved.
//

import Alamofire

/// This class represents the current student registered on this device.
public final class Student: NSObject, NSSecureCoding {
    
    /// Shared instance.
    public private(set) static var shared = NSKeyedUnarchiver.unarchiveObjectWithFile(savedFilePath) as? Student
    
    /// Path to saved data.
    private static let savedFilePath = NSFileManager().containerURLForSecurityApplicationGroupIdentifier("group.com.bit2software.RUapp")!.URLByAppendingPathComponent("SavedData").path!
    
    // Keys
    private static let idKey = "student_id"
    private static let nameKey = "name"
    private static let numberPlateKey = "number_plate"
    private static let institutionKey = "institution"
    private static let institutionIdKey = "institution_id"
    
    /// Register a new student on the provided institution. This also saves all data on the device.
    public class func register(name name: String, numberPlate: String, on institution: Institution, completion: (student: Student?, error: ErrorType?) -> Void) {
        
        // Prevent from registering a student again.
        guard shared == nil else {
            completion(student: shared, error: nil)
            NSLog("Tried to register a new student when there is already one registered on this device. Please, update current student instead.")
            return
        }
        
        // Make request
        let req = NSMutableURLRequest(URL: NSURL(string: ServiceURL.registerStudent)!)
        req.HTTPMethod = "POST"
        let params = [institutionIdKey: institution.id, nameKey: name, numberPlateKey: numberPlate, "token": UIDevice.currentDevice().identifierForVendor?.UUIDString ?? ""] as [String:AnyObject]
        req.HTTPBody = params.appPrepare()
        Alamofire.request(req).responseJSON { (response) in
            do {
                // Verify values
                guard response.result.isSuccess else {
                    throw response.result.error ?? Error.NoData
                }
                guard let jsonObj = response.result.value,
                    studentId = jsonObj[idKey] as? Int,
                    rawInstitution = jsonObj[institutionKey] else {
                        throw Error.InvalidObject
                }
                // Save student
                shared = Student(id: studentId, name: name, numberPlate: numberPlate, institution: try institution.update(rawInstitution)).save()
                completion(student: shared, error: nil)
            } catch {
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
    /// Institution where this student is registered on.
    public private(set) var institution: Institution
    
    /// Initialization by values.
    private init(id: Int, name: String, numberPlate: String, institution: Institution) {
        self.id = id
        self.name = name
        self.numberPlate = numberPlate
        self.institution = institution
    }
    
    /// Saves the current student on the disk.
    private func save() -> Student {
        NSKeyedArchiver.archiveRootObject(self, toFile: Student.savedFilePath)
        return self
    }
    
    // MARK: Secure coding
    
    public convenience init?(coder aDecoder: NSCoder) {
        // Decode and verify fields
        guard let
            id = aDecoder.decodeObjectOfClass(NSNumber.self, forKey: Student.idKey)?.integerValue,
            name = aDecoder.decodeObjectOfClass(NSString.self, forKey: Student.nameKey) as? String,
            numberPlate = aDecoder.decodeObjectOfClass(NSString.self, forKey: Student.numberPlateKey) as? String,
            institution = aDecoder.decodeObjectOfClass(Institution.self, forKey: Student.institutionKey) else {
                return nil
        }
        // Initialize
        self.init(id: id, name: name, numberPlate: numberPlate, institution: institution)
    }
    
    public func encodeWithCoder(aCoder: NSCoder) {
        // Encode fields
        aCoder.encodeObject(id as NSNumber, forKey: Student.idKey)
        aCoder.encodeObject(name as NSString, forKey: Student.nameKey)
        aCoder.encodeObject(numberPlate as NSString, forKey: Student.numberPlateKey)
        aCoder.encodeObject(institution, forKey: Student.institutionKey)
    }
    
    public static func supportsSecureCoding() -> Bool {
        return true
    }
}

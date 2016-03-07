//
//  Institution.swift
//  RUapp
//
//  Created by Igor Camilo on 15-09-23.
//  Copyright © 2015 Igor Camilo. All rights reserved.
//

import Alamofire

/// This class represents a institution registered with RUapp.
public final class Institution: NSObject, NSSecureCoding {
    
    // Keys
    public static let ModifiedNotificationName = "InstitutionModifiedNotification"
    private static let idKey = "id"
    private static let nameKey = "name"
    private static let campiKey = "campi"
    
    /// Get a list of all institutions (short version).
    public class func list(completion: (list: [Institution]?, error: ErrorType?) -> Void) {
        Alamofire.request(.GET, ServiceURL.getInstitutionOverviewList).responseJSON { (response) in
            do {
                // Verify result
                guard response.result.isSuccess else {
                    throw response.result.error ?? Error.NoData
                }
                guard let jsonObj = response.result.value as? [AnyObject] else {
                    throw Error.InvalidObject
                }
                // Make array and return
                var overviewList = [Institution]()
                for institutionDict in jsonObj {
                    overviewList.append(try Institution(dict: institutionDict))
                }
                completion(list: overviewList, error: nil)
            } catch {
                completion(list: nil, error: error)
            }
        }
    }
    
    private class func extract(dict: AnyObject?) throws -> (id: Int, name: String, campi: [Campus]?) {
        
        guard let
            id = dict?[Institution.idKey] as? Int,
            name = dict?[Institution.nameKey] as? String else {
                throw Error.InvalidObject
        }
        
        let campi: [Campus]?
        if let rawCampi = dict?[Institution.campiKey] as? [AnyObject] {
            var campiArray = [Campus]()
            for campus in rawCampi {
                campiArray.append(try Campus(dict: campus))
            }
            campi = campiArray
        }
        else {
            campi = nil
        }
        
        return (id, name, campi)
    }
    
    // MARK: Instance
        
    public let id: Int
    public private(set) var name: String
    public private(set) var campi: [Campus]?
    
    init(id: Int, name: String, campi: [Campus]?) {
        self.id = id
        self.name = name
        self.campi = campi
    }
    
    convenience init(dict: AnyObject?) throws {
        let extracted = try Institution.extract(dict)
        self.init(id: extracted.id, name: extracted.name, campi: extracted.campi)
    }
    
    func update(dict: AnyObject?) throws -> Institution {
        let extracted = try Institution.extract(dict)
        name = extracted.name
        campi = extracted.campi
        NSNotificationCenter.defaultCenter().postNotificationName(Institution.ModifiedNotificationName, object: self)
        return self
    }
    
    // MARK: NSCoding
    
    public convenience init?(coder aDecoder: NSCoder) {
        
        guard let
            id = aDecoder.decodeObjectOfClass(NSNumber.self, forKey: Institution.idKey) as? Int,
            name = aDecoder.decodeObjectOfClass(NSString.self, forKey: Institution.nameKey) as? String,
            campi = aDecoder.decodeObjectOfClass(NSArray.self, forKey: Institution.campiKey) as? [Campus] else {
                return nil
        }
        
        self.init(id: id, name: name, campi: campi)
    }
    
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(id as NSNumber, forKey: Institution.idKey)
        aCoder.encodeObject(name as NSString, forKey: Institution.nameKey)
        if let campi = campi {
            aCoder.encodeObject(campi as NSArray, forKey: Institution.campiKey)
        }
    }
    
    public static func supportsSecureCoding() -> Bool {
        return true
    }
}
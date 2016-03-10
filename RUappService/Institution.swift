//
//  Institution.swift
//  RUapp
//
//  Created by Igor Camilo on 15-09-23.
//  Copyright © 2015 Igor Camilo. All rights reserved.
//

import Alamofire

/// This class represents a institution registered with RUapp.
public final class Institution {
    
    /// Shared instance.
    public private(set) static var shared = try? Institution(dict: globalUserDefaults.objectForKey(savedDataKey))
    
    // Private keys
    private static let savedDataKey = "saved_institution"
    
    /// Get a list of all institutions (short version).
    public class func list(completion: (result: Result<[Institution]>) -> Void) {
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
                completion(result: .Success(value: overviewList))
            } catch {
                completion(result: .Failure(error: error))
            }
        }
    }
    
    /// Remove saved data from disk.
    class func clear() {
        shared = nil
        globalUserDefaults.removeObjectForKey(savedDataKey)
        globalUserDefaults.synchronize()
    }
    
    /// Extract values from a dictionary.
    private class func extract(dict: AnyObject?) throws -> (id: Int, name: String, campi: [Campus]?) {
        // Verify fields
        guard let
            id = dict?["id"] as? Int,
            name = dict?["name"] as? String else {
                throw Error.InvalidObject
        }
        // Construct campi array if necessary
        let campi: [Campus]?
        if let rawCampi = dict?["campi"] as? [AnyObject] {
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
    
    /// Id of the institution.
    public let id: Int
    /// Display name of the institution.
    public private(set) var name: String
    /// List of the campi of this institution. If nil, it means that this instance is an overview and needs to call update before being stored.
    public private(set) var campi: [Campus]?
    
    /// Initialization by values.
    private init(id: Int, name: String, campi: [Campus]?) {
        self.id = id
        self.name = name
        self.campi = campi
    }
    
    /// Initialization by plist.
    private convenience init(dict: AnyObject?) throws {
        let extracted = try Institution.extract(dict)
        self.init(id: extracted.id, name: extracted.name, campi: extracted.campi)
    }
    
    /// Update and save this institution locally.
    func update(dict: AnyObject?) throws {
        let extracted = try Institution.extract(dict)
        self.name = extracted.name
        self.campi = extracted.campi
        Institution.shared = self
        globalUserDefaults.setObject(dict, forKey: Institution.savedDataKey)
        globalUserDefaults.synchronize()
    }
    
    /// Institution errors
    enum Error: ErrorType {
        case InvalidObject
        case NoData
    }
}
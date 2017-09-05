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
    public fileprivate(set) static var shared = try? Institution(dict: saved())
    
    // Private keys
    fileprivate static let savedDataKey = "saved_institution"
    
    /// Get a list of all institutions (short version).
    public class func list(_ completion: @escaping (_ result: Result<[Institution]>) -> Void) {
        Alamofire.request(ServiceURL.getInstitutionOverviewList).responseJSON { (response) in
            do {
                // Verify result
                guard response.result.isSuccess else {
                    throw response.result.error ?? Error.noData
                }
                guard let jsonObj = response.result.value as? [[String : Any]] else {
                    throw Error.invalidObject
                }
                // Make array and return
                var overviewList = [Institution]()
                for institutionDict in jsonObj {
                    overviewList.append(try Institution(dict: institutionDict))
                }
                completion(.success(value: overviewList))
            } catch {
                completion(.failure(error: error))
            }
        }
    }
    
    /// Remove saved data from disk.
    class func clear() {
        shared = nil
        globalUserDefaults.removeObject(forKey: savedDataKey)
        globalUserDefaults.synchronize()
    }
    
    /// Extract values from a dictionary.
    fileprivate class func extract(_ dict: [String : Any]) throws -> (id: Int, name: String, campi: [Campus]?) {
        // Verify fields
        guard let rawId = dict["id"] as? String, let id = Int(rawId), let name = dict["name"] as? String  else {
            throw Error.invalidObject
        }
        // Construct campi array if necessary
        let campi = try (dict["campi"] as? [AnyObject])?.map(Campus.init)
        return (id, name, campi)
    }
    
    /// Initialization by plist.
    fileprivate init(dict: [String : Any]) throws {
        let extracted = try Institution.extract(dict)
        // Initialize proprieties
        self.id = extracted.id
        self.name = extracted.name
        self.campi = extracted.campi
    }
    
    // MARK: Instance
    
    /// Id of the institution.
    public let id: Int
    /// Display name of the institution.
    public fileprivate(set) var name: String
    /// List of the campi of this institution. If nil, it means that this instance is an overview and needs to call update before being stored.
    public fileprivate(set) var campi: [Campus]?
    
    /// Update and save this institution locally.
    func update(_ dict: [String : Any]) throws {
        let extracted = try Institution.extract(dict)
        self.name = extracted.name
        self.campi = extracted.campi
        Institution.shared = self
        globalUserDefaults.set(dict, forKey: Institution.savedDataKey)
        globalUserDefaults.synchronize()
    }
    
    /// Institution errors
    enum Error: Swift.Error {
        case invalidObject
        case noData
    }
}

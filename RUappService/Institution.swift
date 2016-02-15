//
//  Institution.swift
//  RUapp
//
//  Created by Igor Camilo on 15-09-23.
//  Copyright © 2015 Igor Camilo. All rights reserved.
//

import Alamofire

private let InstitutionSavedDictionaryKey = "SavedInstitutionDictionary"

public class Institution {
    
    public private(set) static var shared = try? Institution(dict: globalUserDefaults?.objectForKey(InstitutionSavedDictionaryKey))
    
    public let id: Int
    public let name: String
    public let campi: [Campus]?
    
    private init(dict: AnyObject?) throws {
        
        guard let dict = dict as? [String:AnyObject],
            dictId = dict["id"] as? Int,
            dictName = dict["name"] as? String else {
                throw Error.InvalidObject
        }
        
        if let dictCampi = dict["campi"] as? [[String:AnyObject]] {
            var campiArray = [Campus]()
            for campus in dictCampi {
                campiArray.append(try Campus(dict: campus))
            }
            campi = campiArray
        }
        else {
            campi = nil
        }
        
        id = dictId
        name = dictName
    }
    
    public class func getList(completion: (list: [Institution]?, error: ErrorType?) -> Void) {
        Alamofire.request(.GET, ServiceURL.getInstitutionOverviewList).responseJSON { (response) in
            do {
                guard response.result.isSuccess else {
                    throw response.result.error ?? Error.NoData
                }
                guard let jsonObj = response.result.value as? [AnyObject] else {
                    throw Error.InvalidObject
                }
                
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
    
    public class func get(id: Int, completion: (institution: Institution?, error: ErrorType?) -> Void) {
        Alamofire.request(.GET, ServiceURL.getInstitution, parameters: ["id": id]).responseJSON { (response) in
            do {
                guard response.result.isSuccess else {
                    throw response.result.error ?? Error.NoData
                }
                
                let newInstitution = try Institution(dict: response.result.value)
                completion(institution: newInstitution, error: nil)
            } catch {
                completion(institution: nil, error: error)
            }
        }
    }
    
    public func registerWithNewStudent(name: String, studentInstitutionId: String, completion: (student: Student?, institution: Institution?, error: ErrorType?) -> Void) {
        
        let req = NSMutableURLRequest(URL: NSURL(string: ServiceURL.registerStudent)!)
        req.HTTPMethod = "POST"
        let params = ["institution_id": id, "name": name, "number_plate": studentInstitutionId, "token": UIDevice.currentDevice().identifierForVendor?.UUIDString ?? ""] as [String:AnyObject]
        req.HTTPBody = params.appPrepare()
        Alamofire.request(req).responseJSON { (response) in
            debugPrint(response)
            do {
                guard response.result.isSuccess else {
                    throw response.result.error ?? Error.NoData
                }
                
                guard let jsonObj = response.result.value,
                    studentId = jsonObj["student_id"] as? Int,
                    institution = jsonObj["institution"] as? [String:AnyObject] else {
                        throw Error.InvalidObject
                }
                
                try Student.register(studentId, name: name, studentId: studentInstitutionId)
                Institution.shared = try Institution(dict: institution)
                globalUserDefaults?.setObject(institution, forKey: InstitutionSavedDictionaryKey) // It will sync in the next command
                Restaurant.defaultRestaurantId = Institution.shared?.campi?.first?.restaurants.first?.id
                completion(student: Student.shared, institution: Institution.shared, error: nil)
            } catch {
                completion(student: nil, institution: nil, error: error)
            }
        }
    }
}
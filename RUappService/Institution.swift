//
//  Institution.swift
//  RUapp
//
//  Created by Igor Camilo on 15-09-23.
//  Copyright © 2015 Igor Camilo. All rights reserved.
//

private var globalInstitutuion = try? Institution(dict: globalUserDefaults?.dictionaryForKey(InstitutionSavedDictionaryKey))
private let InstitutionSavedDictionaryKey = "SavedInstitutionDictionary"

public class Institution {
    
    public class func shared() -> Institution? {
        return globalInstitutuion
    }
    
    public let id: Int
    public let name: String
    public let campi: [Campus]?
    
    public init(dict: AnyObject?) throws {
        do {
            guard let dict = dict as? [String:AnyObject],
                dictId = dict["id"] as? Int,
                dictName = dict["nome"] as? String else {
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
        catch {
            id = -1
            name = ""
            campi = nil
            throw error
        }
    }
    
    public class func getList(completion: (list: [Institution]?, error: ErrorType?) -> Void) {
        NSURLSession.sharedSession().dataTaskWithURL(NSURL.appGetInstitutionOverviewList(), completionHandler: { (data, response, error) -> Void in
            do {
                guard let data = data,
                    jsonObj = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [AnyObject] else {
                        throw error ?? Error.InvalidObject
                }
                
                var overviewList = [Institution]()
                for institutionDict in jsonObj {
                    overviewList.append(try Institution(dict: institutionDict))
                }
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    completion(list: overviewList, error: nil)
                })
            } catch {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    completion(list: nil, error: error)
                })
            }
        }).resume()
    }
    
    public class func get(id: Int, completion: (institution: Institution?, error: ErrorType?) -> Void) {
        NSURLSession.sharedSession().dataTaskWithURL(NSURL.appGetInstitution(id), completionHandler: { (data, response, error) -> Void in
            
            do {
                guard let data = data else {
                    throw error ?? Error.NoData
                }
                
                let jsonObj = try NSJSONSerialization.JSONObjectWithData(data, options: [])
                let newInstitution = try Institution(dict: jsonObj)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    completion(institution: newInstitution, error: nil)
                })
            } catch {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    completion(institution: nil, error: error)
                })
            }
            
        }).resume()
    }
    
    public func registerWithNewStudent(name: String, studentInstitutionId: String, completion: (student: Student?, institution: Institution?, error: ErrorType?) -> Void) {
        
        let req = NSMutableURLRequest(URL: NSURL.appRegisterStudent())
        req.HTTPMethod = "POST"
        let params = ["instituicao_id": id, "nome": name, "matricula": studentInstitutionId, "token": String(random())] as [String:AnyObject]
        req.HTTPBody = params.appPrepare()
        NSURLSession.sharedSession().dataTaskWithRequest(req, completionHandler: { (data, response, error) -> Void in
            
            do {
                guard let data = data else {
                    throw error ?? Error.NoData
                }
                
                let jsonObj = try NSJSONSerialization.JSONObjectWithData(data, options: [])
                
                guard let studentId = jsonObj["student_id"] as? Int,
                    institution = jsonObj["institution"] as? [String:AnyObject] else {
                        throw Error.InvalidObject
                }
                
                try Student.register(studentId, name: name, studentId: studentInstitutionId)
                globalInstitutuion = try Institution(dict: institution)
                globalUserDefaults?.setObject(institution, forKey: InstitutionSavedDictionaryKey)
                globalUserDefaults?.synchronize()
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    completion(student: nil, institution: globalInstitutuion, error: nil)
                })
            } catch {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    completion(student: nil, institution: nil, error: error)
                })
            }
            
        }).resume()
    }
}
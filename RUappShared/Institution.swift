//
//  Institution.swift
//  RUappShared
//
//  Created by Igor Camilo on 14/09/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

import CoreData

extension Institution {
    static var entityName: String {
        return "Institution"
    }
}

/// Initializers
extension Institution {
    
    func update(from json: JSON.Institution) {
        id = Int64(json.id)!
        name = json.name
        townName = json.townName
        stateName = json.stateName
        stateInitials = json.stateInitials
        campi = NSSet(array: json.campi.map {
            let campus = NSEntityDescription.insertNewObject(forEntityName: Campus.entityName, into: managedObjectContext!) as! Campus
            campus.update(from: $0)
            campus.institution = self
            return campus
        })
    }
}

/// Get from network
extension Institution {
    
    public static func getList(completion: @escaping CompletionHandler<[Overview]>) {
        URLRouter.listInstitutions.request.response { (result) in
            do {
                let list = try JSONDecoder().decode([Overview].self, from: result())
                completion {
                    return list
                }
            } catch {
                completion {
                    throw error
                }
            }
        }
    }
}

/// Subtype
extension Institution {
    public struct Overview: Decodable {
        public var id: String
        public var name: String
    }
}

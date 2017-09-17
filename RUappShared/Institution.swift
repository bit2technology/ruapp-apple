//
//  Institution.swift
//  RUappShared
//
//  Created by Igor Camilo on 14/09/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

public final class Institution: InstitutionProtocol {
    
    public let id: String
    public let name: String
    
    public let cafeterias: [(campusName: String, units: [Cafeteria])]
    public var defaultCafeteria: Cafeteria? {
        didSet {
            NotificationCenter.default.post(name: .defaultCafeteriaChanged, object: defaultCafeteria)
            try? JSONEncoder().encode(JSONDefaultRestaurant(id: defaultCafeteria?.id)).write(to: Institution.defaultCafeteriaPersistenceURL)
        }
    }
    
    private convenience init() throws {
        self.init(json: try JSONDecoder().decode(JSONInstitution.self, from: Data(contentsOf: Institution.persistenceURL)))
    }
    
    private init(json: JSONInstitution) {
        id = json.id
        name = json.name
        let defaultRestaurant = try? JSONDecoder().decode(JSONDefaultRestaurant.self, from: Data(contentsOf: Institution.defaultCafeteriaPersistenceURL))
        var defaultCafeteria: Cafeteria?
        cafeterias = json.campi.map {
            ($0.name, $0.restaurants.map {
                let cafeteria = Cafeteria(json: $0)
                if cafeteria.id == defaultRestaurant?.id {
                    defaultCafeteria = cafeteria
                }
                return cafeteria
            })
        }
        self.defaultCafeteria = defaultCafeteria
    }
    
    // MARK: Static
    
    public private(set) static var shared = try? Institution()
    
    public static func get(id: String, completion: @escaping CompletionHandler<Institution>) {
        URLRouter.institution(id: id).request.response { (result) in
            do {
                let json = try JSONDecoder().decode(JSONInstitution.self, from: result())
                let institution = Institution(json: json)
                completion {
                    return institution
                }
            } catch {
                completion {
                    throw error
                }
            }
        }
    }
    
    public static func getList(completion: @escaping CompletionHandler<[Overview]>) {
        URLRouter.listInstitutions.request.response { (result) in
            do {
                let list = try JSONDecoder().decode([JSONInstitution.Overview].self, from: result()).map(Overview.init)
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
    
    public static func unregister() throws {
        shared = nil
        try FileManager.default.removeItem(at: persistenceURL)
    }
    
    static func localRegister(json: JSONInstitution) throws {
        let encoder = JSONEncoder()
        if let restaurantId = json.campi.first?.restaurants.first?.id {
            try encoder.encode(JSONDefaultRestaurant(id: restaurantId)).write(to: defaultCafeteriaPersistenceURL)
        }
        try encoder.encode(json).write(to: persistenceURL)
        shared = Institution(json: json)
        NotificationCenter.default.post(name: .defaultCafeteriaChanged, object: shared?.defaultCafeteria)
    }
    
    private static var persistenceURL: URL {
        return sharedDirectoryURL().appendingPathComponent("institution.json")
    }
    
    private static var defaultCafeteriaPersistenceURL: URL {
        return sharedDirectoryURL().appendingPathComponent("default_restaurant.json")
    }
    
    public class Overview: InstitutionProtocol {
        
        public let id: String
        public let name: String
        
        init(json: JSONInstitution.Overview) {
            id = json.id
            name = json.name
        }
    }
}

public protocol InstitutionProtocol {
    var id: String { get }
    var name: String { get }
}

private struct JSONDefaultRestaurant: Codable {
    var id: String?
}

public extension Notification.Name {
    static var defaultCafeteriaChanged: Notification.Name {
        return Notification.Name(rawValue: "Institution.defaultCafeteriaChanged")
    }
}

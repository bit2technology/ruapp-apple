//
//  Institution.swift
//  RUappShared
//
//  Created by Igor Camilo on 14/09/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

public final class Institution {
    
    private var json: JSONInstitution
    
    private convenience init() throws {
        self.init(json: try JSONDecoder().decode(JSONInstitution.self, from: Data(contentsOf: Institution.persistenceURL)))
    }
    
    private init(json: JSONInstitution) {
        self.json = json
    }
    
    // MARK: Static
    
    public private(set) static var shared = try? Institution()
    
    public static func unregister() throws {
        shared = nil
        try FileManager.default.removeItem(at: persistenceURL)
    }
    
    static func localRegister(json: JSONInstitution) throws {
        try JSONEncoder().encode(json).write(to: persistenceURL)
        shared = Institution(json: json)
    }
    
    private static var persistenceURL: URL {
        return sharedDirectoryURL().appendingPathComponent("institution.json")
    }
}

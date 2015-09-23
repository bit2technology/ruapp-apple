//
//  Institution.swift
//  RUapp
//
//  Created by Igor Camilo on 15-09-23.
//  Copyright © 2015 Igor Camilo. All rights reserved.
//

public class Institution {
    
    public let id: Int
    public let name: String
    public let campi: [Campus]
    
    public init(dict: AnyObject?) throws {
        do {
            guard let dict = dict as? [String:AnyObject],
                dictId = dict["id"] as? Int,
                dictName = dict["nome"] as? String,
                dictCampi = dict["campi"] as? [[String:AnyObject]] else {
                    throw RUappServiceError.InvalidObject
            }
            
            var campiArray = [Campus]()
            for campus in dictCampi {
                campiArray.append(try Campus(dict: campus))
            }
            id = dictId
            name = dictName
            campi = campiArray
        }
        catch {
            id = -1
            name = ""
            campi = []
            throw error
        }
    }
}
//
//  Campus.swift
//  RUapp
//
//  Created by Igor Camilo on 15-09-23.
//  Copyright © 2015 Igor Camilo. All rights reserved.
//

public class Campus {
    
    public let id: Int
    public let name: String
    public let cafeterias: [Cafeteria]
    
    public init(dict: AnyObject?) throws {
        do {
            guard let dict = dict as? [String:AnyObject],
                dictInt = dict["id"] as? Int,
                dictName = dict["nome"] as? String,
                dictCafe = dict["restaurantes"] as? [[String:AnyObject]] else {
                    throw Error.InvalidObject
            }
            
            var cafeArray = [Cafeteria]()
            for cafeteria in dictCafe {
                cafeArray.append(try Cafeteria(dict: cafeteria))
            }
            id = dictInt
            name = dictName
            cafeterias = cafeArray
        }
        catch {
            id = -1
            name = ""
            cafeterias = []
            throw error
        }
    }
}
//
//  Cafeteria.swift
//  RUapp
//
//  Created by Igor Camilo on 15-09-23.
//  Copyright © 2015 Igor Camilo. All rights reserved.
//

import CoreLocation

public class Cafeteria {
    
    public let id: Int
    public let name: String
    public let capacity: Int?
    public let coordinate: CLLocationCoordinate2D
    public let meals: [Meal]
    
    public init(dict: AnyObject?) throws {
        do {
            guard let dict = dict as? [String:AnyObject],
                dictId = dict["id"] as? Int,
                dictName = dict["nome"] as? String,
                latitude = dict["latitude"] as? CLLocationDegrees,
                longitude = dict["longitude"] as? CLLocationDegrees,
                dictMeals = dict["tipos_refeicao"] as? [AnyObject] else {
                    throw RUappServiceError.InvalidObject
            }
            
            var mealsArray = [Meal]()
            for refeicao in dictMeals {
                mealsArray.append(try Meal(dict: refeicao))
            }
            id = dictId
            name = dictName
            capacity = dict["capacidade"] as? Int
            coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            meals = mealsArray
        }
        catch {
            id = -1
            name = ""
            capacity = nil
            coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
            meals = []
            throw error
        }
    }
}
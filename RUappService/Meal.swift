//
//  Meal.swift
//  RUapp
//
//  Created by Igor Camilo on 15-09-23.
//  Copyright © 2015 Igor Camilo. All rights reserved.
//

public class Meal {
    
    public let id: Int
    public let name: String
    public let running: [Running]
    
    public init(dict: AnyObject?) throws {
        do {
            guard let dict = dict as? [String:AnyObject],
                dictId = dict["id"] as? Int,
                dictName = dict["nome"] as? String,
                dictRunning = dict["funcionamentos"] as? [AnyObject] else {
                    throw RUappServiceError.InvalidObject
            }
            
            var runningArray = [Running]()
            for piece in dictRunning {
                runningArray.append(try Running(dict: piece))
            }
            id = dictId
            name = dictName
            running = runningArray
        }
        catch {
            id = -1
            name = ""
            running = []
            throw error
        }
    }
    
    public class Running {
        
        public let dayOfWeek: Int
        public let opening: String
        public let closing: String
        
        public init(dict: AnyObject?) throws {
            
            guard let dict = dict as? [String:AnyObject],
                dictDay = dict["dia_da_semana"] as? Int,
                dictOpen = dict["horario_abertura"] as? String,
                dictClose = dict["horario_fechamento"] as? String else {
                    dayOfWeek = -1
                    opening = ""
                    closing = ""
                    throw RUappServiceError.InvalidObject
            }
            
            dayOfWeek = dictDay
            opening = dictOpen
            closing = dictClose
        }
    }
}
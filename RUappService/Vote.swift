//
//  Vote.swift
//  RUapp
//
//  Created by Igor Camilo on 15-09-29.
//  Copyright © 2015 Igor Camilo. All rights reserved.
//

public class Vote {
    
    public var type: Type?
    public var reason: [Int]?
    public var comment: String?
    
    public class func dishes(num: Int) -> [Vote] {
        var votes = [Vote]()
        for _ in 1..<num {
            votes.append(Vote())
        }
        return votes
    }
    
    public enum Type: Int {
        case DidntEat = 0, Bad, Good, VeryGood
    }
}
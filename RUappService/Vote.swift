//
//  Vote.swift
//  RUapp
//
//  Created by Igor Camilo on 15-09-29.
//  Copyright © 2015 Igor Camilo. All rights reserved.
//

public class Vote {
    
    public var type: VoteType?
    public var reason: Set<Int>?
    public var comment: String?
    public var sent = false
    
    public init() {}
    
    public enum VoteType: Int {
        case DidntEat = 0, Bad, Good, VeryGood
    }
}
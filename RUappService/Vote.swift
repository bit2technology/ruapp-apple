//
//  Vote.swift
//  RUapp
//
//  Created by Igor Camilo on 16-03-10.
//  Copyright © 2016 Igor Camilo. All rights reserved.
//

public class Vote {
    
    public var item: Votable
    public var type: VoteType?
    public var reason: Set<Int>?
    public var comment: String?
    
    public init(item: Votable) {
        self.item = item
    }
    
    private func toRawDict() throws -> [String:AnyObject] {
        // Verify values
        guard let type = type else {
            throw Error.InvalidVote
        }
        // Build dictionary
        var dict = ["dish_id": item.id, "vote_type_id": type.rawValue] as [String:AnyObject]
        if let reason = reason where !reason.isEmpty {
            dict["pre_defined_comment_ids"] = Array(reason)
        }
        if let comment = comment {
            dict["comment"] = comment
        }
        // Return dictionary
        return dict
    }
    
    public enum VoteType: Int {
        case DidntEat = 0
        case Bad = 1
        case Good = 2
        case VeryGood = 3
    }
    
    enum Error: ErrorType {
        case InvalidMeal
        case InvalidVote
    }
}

public extension Array where Element : Vote {
    
    public func send(for meal: Meal, completion: (result: Result<AnyObject>) -> Void) {
        
        guard let mealId = meal.id else {
            completion(result: .Failure(error: Vote.Error.InvalidMeal))
            return
        }
        
        var votesDict = [AnyObject]()
        for vote in self {
            
        }
    }
    
}
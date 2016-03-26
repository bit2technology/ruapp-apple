//
//  Vote.swift
//  RUapp
//
//  Created by Igor Camilo on 16-03-10.
//  Copyright © 2016 Igor Camilo. All rights reserved.
//

import Alamofire

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
            throw Error.NoType
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
        case InvalidInfo
        case NoType
        case NoData
    }
}

public extension Array where Element : Vote {
    
    public func send(completion: (result: Result<AnyObject>) -> Void) {
        do {
            guard let mealId = Menu.shared?.currentMeal?.id,
                studentId = Student.shared?.id else {
                    completion(result: .Failure(error: Vote.Error.InvalidInfo))
                    return
            }
            
            var votesDict = [AnyObject]()
            for vote in self {
                votesDict.append(try vote.toRawDict())
            }
            
            let req = NSMutableURLRequest(URL: NSURL(string: ServiceURL.sendVote)!)
            req.HTTPMethod = "POST"
            let params = ["student_id": studentId, "meal_id": mealId, "votes": votesDict]
            req.HTTPBody = params.appPrepare()
            Alamofire.request(req).responseJSON { (response) in
                print("vote completed success:", response.result.isSuccess, response.result.value)
            }
        } catch {
            completion(result: .Failure(error: error))
            return
        }
    }
}
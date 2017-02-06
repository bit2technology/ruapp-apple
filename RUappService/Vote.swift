//
//  Vote.swift
//  RUapp
//
//  Created by Igor Camilo on 16-03-10.
//  Copyright © 2016 Igor Camilo. All rights reserved.
//

import Alamofire

open class Vote {
    
    open var item: Votable
    open var type: VoteType?
    open var reason: Set<Int>?
    open var comment: String?
    
    public init(item: Votable) {
        self.item = item
    }
    
    fileprivate func toRawDict() throws -> [String:AnyObject] {
        // Verify values
        guard let type = type else {
            throw Error.noType
        }
        // Build dictionary
        var dict = ["dish_id": item.id as AnyObject, "vote_type_id": type.rawValue as AnyObject] as [String:AnyObject]
        if let reason = reason, !reason.isEmpty {
            dict["pre_defined_comment_ids"] = Array(reason) as AnyObject?
        }
        if let comment = comment {
            dict["comment"] = comment as AnyObject?
        }
        // Return dictionary
        return dict
    }
    
    public enum VoteType: Int {
        case didntEat = 0
        case bad = 1
        case good = 2
        case veryGood = 3
    }
    
    enum Error: Swift.Error {
        case invalidInfo
        case noType
        case noData
    }
}

public extension Array where Element : Vote {
    
    public func send(_ completion: (_ result: Result<AnyObject>) -> Void) {
        do {
            guard let mealId = Menu.shared?.currentMeal?.id,
                let studentId = Student.shared?.id else {
                    completion(.failure(error: Vote.Error.invalidInfo))
                    return
            }
            
            var votesDict = [AnyObject]()
            for vote in self {
                votesDict.append(try vote.toRawDict() as AnyObject)
            }
            
            var req = URLRequest(url: URL(string: ServiceURL.sendVote)!)
            req.httpMethod = "POST"
            let params = ["student_id": studentId, "meal_id": mealId, "votes": votesDict] as [String : Any]
            req.httpBody = params.appPrepare()
            Alamofire.request(req).responseJSON { (response) in
                print("vote completed success:", response.result.isSuccess, response.result.value)
            }
        } catch {
            completion(.failure(error: error))
            return
        }
    }
}

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
    private var sending = false
    private var sent = false
    
    private func appPrepare() -> String {
        let string = "{\"comida_id\":\\(item.id),\"tipo_voto_id\":1,\"comentario\":\"Delicioso\",\"comentario_pre_definido_id\":[14, 12, 9]}"
        return string
    }
    
    public init(item: Votable) {
        self.item = item
    }
    
    public enum VoteType: Int {
        case DidntEat = 0, Bad, Good, VeryGood
    }
    
    public func send() {
        
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
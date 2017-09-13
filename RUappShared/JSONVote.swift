//
//  JSONVote.swift
//  RUappShared
//
//  Created by Igor Camilo on 13/09/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

struct JSONVote: Codable {
    var mealId: Int
    var studentId: Int
    var votes: [Dish]
    
    enum CodingKeys: String, CodingKey {
        case mealId = "meal_id"
        case studentId = "student_id"
        case votes
    }
    
    struct Dish: Codable {
        var voteTypeId: Int
        var id: Int
        var comment: String
        var preDefinedCommentIds: Set<Int>
        
        enum CodingKeys: String, CodingKey {
            case voteTypeId = "vote_type_id"
            case id = "dish_id"
            case comment
            case preDefinedCommentIds = "pre_defined_comment_ids"
        }
    }
}

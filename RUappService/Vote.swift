//
//  Vote.swift
//  RUapp
//
//  Created by Igor Camilo on 15-09-29.
//  Copyright © 2015 Igor Camilo. All rights reserved.
//

public class Vote {
    
    public var item: Menu.Item
    public var type: VoteType?
    public var reason: Set<Int>?
    public var comment: String?
    public var sent = false
    
    private func appPrepare() -> String {
        var string = "{\"comida_id\":\(item.id),\"tipo_voto_id\":1,\"comentario\":\"Delicioso\",\"comentario_pre_definido_id\":[14, 12, 9]}"
        return string
    }
    
    public init(item: Menu.Item) {
        self.item = item
    }
    
    public enum VoteType: Int {
        case DidntEat = 0, Bad, Good, VeryGood
    }
    
    public func send() {
        
    }
}
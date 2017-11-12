//
//  GetMenuOperation.swift
//  RUappShared
//
//  Created by Igor Camilo on 10/11/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

class GetMenuOperation: URLSessionDataTaskOperation {
    
    init(restaurantId: Int64) {
        super.init(request: URLRoute.menu(restaurantId: restaurantId).urlRequest)
    }
    
    func parse() throws -> [JSON.Menu] {
        return try JSONDecoder().decode([JSON.Menu].self, from: value())
    }
}

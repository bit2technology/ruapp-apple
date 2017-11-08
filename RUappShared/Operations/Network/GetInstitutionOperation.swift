//
//  GetInstitutionOperation.swift
//  RUappShared
//
//  Created by Igor Camilo on 07/11/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

class GetInstitutionOperation: URLSessionDataTaskOperation {
    
    init(id: Int) {
        super.init(request: URLRoute.getInstitution(id: id).urlRequest!)
    }
    
    func parse() throws -> JSON.Institution {
        return try JSONDecoder().decode(JSON.Institution.self, from: value())
    }
}

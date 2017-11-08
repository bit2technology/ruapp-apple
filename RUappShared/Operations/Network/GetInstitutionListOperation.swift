//
//  GetInstitutionListOperation.swift
//  RUappShared
//
//  Created by Igor Camilo on 07/11/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

class GetInstitutionListOperation: URLSessionDataTaskOperation {
    
    init() {
        super.init(request: URLRoute.getInstitutionsList.urlRequest!)
    }
    
    func parse() throws -> [JSON.Institution] {
        return try JSONDecoder().decode([JSON.Institution].self, from: value())
    }
}

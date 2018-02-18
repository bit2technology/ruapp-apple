//
//  JSONDecoder+Persistent.swift
//  RUappShared
//
//  Created by Igor Camilo on 18/02/18.
//  Copyright © 2018 Bit2 Technology. All rights reserved.
//

import CoreData

extension JSONDecoder {
    
    static func persistent(context: NSManagedObjectContext) -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.userInfo[.managedObjectContext] = context
        return decoder
    }
}

extension CodingUserInfoKey {
    
    static let managedObjectContext = CodingUserInfoKey(rawValue: "ManagedObjectContext")!
}

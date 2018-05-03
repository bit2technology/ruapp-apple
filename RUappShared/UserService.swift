//
//  UserService.swift
//  RUappShared
//
//  Created by Igor Camilo on 28/04/18.
//  Copyright © 2018 Bit2 Technology. All rights reserved.
//

public enum UserService {

    fileprivate static func loadFromDisk() -> User? {
        fatalError("Not implemented yet!")
    }
}

extension User {
    public fileprivate(set) static var current = UserService.loadFromDisk()
}

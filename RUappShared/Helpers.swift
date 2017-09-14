//
//  Helpers.swift
//  RUappShared
//
//  Created by Igor Camilo on 13/09/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

public typealias CompletionHandler<T> = (() throws -> T) -> Void

let defaultInstitutionId = 1

func sharedDirectoryURL() -> URL {
    return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.technology.bit2.ruapp")!
}

//
//  Helpers.swift
//  RUappShared
//
//  Created by Igor Camilo on 13/09/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

public typealias CompletionHandler<T> = (() throws -> T) -> Void

func sharedDirectoryURL() -> URL {
    return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.technology.bit2.ruapp")!
}

extension String {
    var percentEncoding: String {
        return addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
    }
    var data: Data? {
        return data(using: .utf8)
    }
}

extension Data {
    var string: String? {
        return String(data: self, encoding: .utf8)
    }
}

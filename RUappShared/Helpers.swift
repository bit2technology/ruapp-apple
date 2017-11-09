//
//  Helpers.swift
//  RUappShared
//
//  Created by Igor Camilo on 13/09/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

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

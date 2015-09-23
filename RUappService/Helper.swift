//
//  Helper.swift
//  RUapp
//
//  Created by Igor Camilo on 15-09-23.
//  Copyright © 2015 Igor Camilo. All rights reserved.
//

extension Dictionary {
    func appPrepare() -> NSData? {
        var string = "requisitionData={"
        for (idx, key) in keys.enumerate() {
            if idx > 0 {
                string += ","
            }
            string += "\"\(key)\":"
            let value = self[key]!
            if value is Int || value is Double {
                string += String(value)
            } else if let valueStr = value as? String, valuePercent = valueStr.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.alphanumericCharacterSet()) {
                string += "\"\(valuePercent)\""
            } else {
                string += "\"\(value)\""
            }
        }
        return (string + "}").dataUsingEncoding(NSUTF8StringEncoding)
    }
}

extension NSURL {
    class func appRegisterStudent() -> NSURL {
        return NSURL(string: "http://45.55.77.200/api/v1/cadastroaluno")!
    }
    class func appGetInstitution(id: Int) -> NSURL {
        return NSURL(string: "http://45.55.77.200/api/v1/instituicao?id=\(id)")!
    }
    class func appGetInstitutionOverviewList() -> NSURL {
        return NSURL(string: "http://45.55.77.200/api/v1/instituicoes")!
    }
}
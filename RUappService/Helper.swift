//
//  Helper.swift
//  RUapp
//
//  Created by Igor Camilo on 15-09-23.
//  Copyright © 2015 Igor Camilo. All rights reserved.
//

extension NSDictionary {
    func appPrepare() -> NSData? {
        guard let
            jsonData = try? NSJSONSerialization.dataWithJSONObject(self, options: []),
            string = String(data: jsonData, encoding: NSUTF8StringEncoding) else {
                return nil
        }
        return ("requisitionData=" + string).dataUsingEncoding(NSUTF8StringEncoding)
    }
}
//
//  String+Custom.swift
//  RUapp-iOS
//
//  Created by Igor Camilo on 17/09/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

extension String {
    var relevant: String? {
        return count > 0 ? self : nil
    }
}

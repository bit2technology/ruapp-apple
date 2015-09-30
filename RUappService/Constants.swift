//
//  Constants.swift
//  RUapp
//
//  Created by Igor Camilo on 15-09-23.
//  Copyright © 2015 Igor Camilo. All rights reserved.
//

public enum RUappServiceError: ErrorType {
    case InvalidObject
    case Unknown
}

public let globalUserDefaults = NSUserDefaults(suiteName: "group.com.bit2software.RUapp")
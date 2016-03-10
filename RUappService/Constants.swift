//
//  Constants.swift
//  RUapp
//
//  Created by Igor Camilo on 15-09-23.
//  Copyright © 2015 Igor Camilo. All rights reserved.
//

public let globalUserDefaults = NSUserDefaults(suiteName: "group.com.bit2software.RUapp")!

class ServiceURL {
    static let registerStudent = "http://www.ruapp.com.br/api/v1/student"
    static let getInstitution = "http://www.ruapp.com.br/api/v1/institution"
    static let getInstitutionOverviewList = "http://www.ruapp.com.br/api/v1/institutions"
    static let getMenu = "http://www.ruapp.com.br/api/v1/menu"
}

public enum Result<T> {
    case Success(value: T)
    case Failure(error: ErrorType)
}
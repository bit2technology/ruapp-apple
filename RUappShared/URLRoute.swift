//
//  URLRoute.swift
//  RUappShared
//
//  Created by Igor Camilo on 14/09/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

import Foundation

enum URLRoute {
    case getInstitutions
    case getInstitution(id: Int64)
    case getStudent(id: Int64)
    case postStudent(Student)
    case patchStudent(Student)
    case menu(restaurantId: Int64)
}

extension URLRoute {
    var urlRequest: URLRequest {
        var urlBuilder = "https://www.ruapp.com.br/api/v2/"
        var httpMethod = HTTPMethod.get
        var httpHeader: [String: String] = [:]
        var httpBody: Data?
        
        switch self {
        case .getInstitutions:
            urlBuilder += "institutions"
        case .getInstitution(let id):
            urlBuilder += "institutions/\(id)"
        case .getStudent(let id):
            urlBuilder += "students/\(id)"
        case .postStudent(let student):
            urlBuilder += "students"
            httpMethod = .post
            httpHeader = ["Content-Type": "application/json"]
            httpBody = try! JSONEncoder().encode(student)
        case .patchStudent(let student):
            urlBuilder += "students/\(student.id)"
            httpMethod = .patch
            httpHeader = ["Content-Type": "application/json"]
            httpBody = try! JSONEncoder().encode(student)
        case .menu(let restaurantId):
            urlBuilder += "menu?restaurant_id=\(restaurantId)"
        }
        
        var req = URLRequest(url: URL(string: urlBuilder)!)
        req.httpMethod = httpMethod.rawValue
        httpHeader.forEach { (key, value) in
            req.setValue(value, forHTTPHeaderField: key)
        }
        req.httpBody = httpBody
        return req
    }
}

private enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case patch = "PATCH"
}

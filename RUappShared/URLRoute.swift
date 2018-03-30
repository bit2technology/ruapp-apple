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
  case postStudent(Data)
  case patchStudent(id: Int64, Data)
  case menu(cafeteriaId: Int64)

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
      httpBody = student
    case .patchStudent(let id, let student):
      urlBuilder += "students/\(id)"
      httpMethod = .patch
      httpHeader = ["Content-Type": "application/json"]
      httpBody = student
    case .menu(let cafeteriaId):
      urlBuilder += "menu?restaurant_id=\(cafeteriaId)"
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

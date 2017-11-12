//
//  URLRoute.swift
//  RUappShared
//
//  Created by Igor Camilo on 14/09/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

/// API endpoints.
enum URLRoute {
    case getInstitutionsList
    case getInstitution(id: Int64)
    case register(student: JSON.Student)
    case edit(studentId: Int64, values: JSON.Student)
    case menu(restaurantId: Int64)
}

extension URLRoute {
    var urlRequest: URLRequest {
        var urlBuilder = "https://www.ruapp.com.br/api/v1/"
        var httpMethod = HTTPMethod.get
        var httpHeader: [String: String] = [:]
        var httpBody: Data?
        
        switch self {
        case .getInstitutionsList:
            urlBuilder += "institutions"
        case .getInstitution(let id):
            urlBuilder += "institution?id=\(id)"
        case .register(let student):
            urlBuilder += "register_student"
            httpMethod = .post
            httpBody = try! student.requisitionData()
        case .edit(let studentId, let values):
            urlBuilder += "register_student/\(studentId)"
            httpMethod = .put
            httpHeader = ["Content-Type": "application/x-www-form-urlencoded"]
            httpBody = "\(JSON.Student.CodingKeys.name.rawValue)=\(values.name.percentEncoding)&\(JSON.Student.CodingKeys.numberPlate.rawValue)=\(values.numberPlate.percentEncoding)&\(JSON.Student.CodingKeys.institutionId.rawValue)=\(values.institutionId)".data(using: .utf8)!
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
    case put = "PUT"
}

private extension Encodable {
    func requisitionData() throws -> Data {
        return try "requisitionData=".data(using: .utf8)! + JSONEncoder().encode(self)
    }
}

private extension String {
    var percentEncoding: String {
        return addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
    }
}

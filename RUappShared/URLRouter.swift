//
//  URLRouter.swift
//  RUappShared
//
//  Created by Igor Camilo on 14/09/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

enum URLRouter {
    case register(student: JSONStudent)
    
    var request: URLRequest {
        var urlBuilder = "https://www.ruapp.com.br/api/v1/"
        var httpMethod = HTTPMethod.get
        var httpBody: Data?
        
        switch self {
        case .register(let student):
            urlBuilder += "register_student"
            httpMethod = .post
            httpBody = student.requisitionData()
        }
        
        var req = URLRequest(url: URL(string: urlBuilder)!)
        req.httpMethod = httpMethod.rawValue
        req.httpBody = httpBody
        return req
    }
    
    private enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
    }
}

private extension Encodable {
    func requisitionData() -> Data {
        let data = try! JSONEncoder().encode(self)
        let string = String(data: data, encoding: .utf8)!
        return ("requisitionData=" + string).data(using: .utf8)!
    }
}

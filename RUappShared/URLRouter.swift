//
//  URLRouter.swift
//  RUappShared
//
//  Created by Igor Camilo on 14/09/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

enum URLRouter {
    case listInstitutions
    case register(student: JSONStudent)
    case edit(student: JSONStudent)
    
    var request: URLRequest {
        var urlBuilder = "https://www.ruapp.com.br/api/v1/"
        var httpMethod = HTTPMethod.get
        var httpBody: Data?
        
        switch self {
        case .listInstitutions:
            urlBuilder += "institutions"
        case .register(let student):
            urlBuilder += "register_student"
            httpMethod = .post
            httpBody = student.requisitionData()
        case .edit(let student):
            urlBuilder += "register_student/\(student.id!)"
            httpMethod = .put
            httpBody = "\(JSONStudent.CodingKeys.name.rawValue)=\(student.name.percentEncoding)&\(JSONStudent.CodingKeys.numberPlate.rawValue)=\(student.numberPlate.percentEncoding)&\(JSONStudent.CodingKeys.institutionId.rawValue)=\(student.institutionId)".data!
        }
        
        #if DEBUG
            print("Request url:\(urlBuilder) method:\(httpMethod) body:\(httpBody?.string ?? "")")
        #endif
        
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
        let string = data.string!
        return ("requisitionData=" + string).data!
    }
}

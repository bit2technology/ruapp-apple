//
//  URLRouter.swift
//  RUappShared
//
//  Created by Igor Camilo on 14/09/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

enum URLRouter {
    case listInstitutions
    case institution(id: String)
    case register(student: JSON.Student)
    case edit(studentId: Int, values: JSON.Student)
    
    var request: URLRequest {
        var urlBuilder = "https://www.ruapp.com.br/api/v1/"
        var httpMethod = HTTPMethod.get
        var httpBody: Data?
        
        switch self {
        case .listInstitutions:
            urlBuilder += "institutions"
        case .institution(let id):
            urlBuilder += "institution?id=\(id)"
        case .register(let student):
            urlBuilder += "register_student"
            httpMethod = .post
            httpBody = student.requisitionData()
        case .edit(let studentId, let values):
            urlBuilder += "register_student/\(studentId)"
            httpMethod = .put
            httpBody = "\(JSON.Student.CodingKeys.name.rawValue)=\(values.name.percentEncoding)&\(JSON.Student.CodingKeys.numberPlate.rawValue)=\(values.numberPlate.percentEncoding)&\(JSON.Student.CodingKeys.institutionId.rawValue)=\(values.institutionId)".data!
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

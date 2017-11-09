//
//  RegisterStudentOperation.swift
//  RUappShared
//
//  Created by Igor Camilo on 08/11/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

class RegisterStudentOperation: URLSessionDataTaskOperation {
    
    init(student: JSON.Student) {
        super.init(request: URLRoute.register(student: student).urlRequest)
    }
    
    func parse() throws -> JSON.RegisteredStudent {
        return try JSONDecoder().decode(JSON.RegisteredStudent.self, from: value())
    }
}

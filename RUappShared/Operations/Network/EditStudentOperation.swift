//
//  EditStudentOperation.swift
//  RUappShared
//
//  Created by Igor Camilo on 08/11/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

class EditStudentOperation: URLSessionDataTaskOperation {
    
    init(studentId: Int64, values: JSON.Student) {
        super.init(request: URLRoute.edit(studentId: studentId, values: values).urlRequest)
    }
    
    func parse() throws -> Bool {
        return try String(data: value(), encoding: .utf8) == "success"
    }
}

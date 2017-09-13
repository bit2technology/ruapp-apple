//
//  JSONStudent.swift
//  RUappShared
//
//  Created by Igor Camilo on 13/09/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

struct JSONStudent: Encodable {
    var name: String
    var numberPlate: String
    var institutionId: Int
    
    enum CodingKeys: String, CodingKey {
        case name
        case numberPlate = "number_plate"
        case institutionId = "institution_id"
    }
}

struct JSONStudentRegistered: Decodable {
    var studentId: Int
    var institution: JSONInstitution
    
    enum CodingKeys: String, CodingKey {
        case studentId = "student_id"
        case institution
    }
}

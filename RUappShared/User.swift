//
//  User.swift
//  RUappShared
//
//  Created by Igor Camilo on 28/04/18.
//  Copyright © 2018 Bit2 Technology. All rights reserved.
//

public class User {
    public let studentId: Int64
    public var studentName: String?
    public var studentInstitution: Institution?
    public var studentNumberPlate: String?
    public var defaultCafeteria: Cafeteria?

    init(studentId: Int64) {
        self.studentId = studentId
    }
}

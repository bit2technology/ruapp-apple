//
//  Student.swift
//  RUappShared
//
//  Created by Igor Camilo on 13/09/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

import CoreData

extension Student {

    public override func validateForInsert() throws {
        try super.validateForInsert()
        try validateConsistency()
    }

    public override func validateForUpdate() throws {
        try super.validateForUpdate()
        try validateConsistency()
    }

    private func validateConsistency() throws {
        guard institution != nil else {
            throw StudentError.noInstitution
        }
    }
}

extension Student: Encodable {

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(numberPlate, forKey: .numberPlate)
        try container.encode(institution?.id, forKey: .institutionId)
    }

    enum CodingKeys: String, CodingKey {
        case name
        case numberPlate = "number_plate"
        case institutionId = "institution_id"
    }
}

public enum StudentError: Error {
    case noInstitution
}

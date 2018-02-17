//
//  CoreDataTests.swift
//  RUappSharedTests-iOS
//
//  Created by Igor Camilo on 18/09/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

import XCTest
@testable import RUappShared

class CoreDataTests: XCTestCase {
    
    func testRegister() {
        let institutionJSON: JSONInstitution = try! decodedMockData(name: "Institution")
        let studentJSON = JSONStudent(name: "Student Name", numberPlate: "Number Plate", institutionId: institutionJSON.id)
        let container = JSONRegisteredStudent(studentId: 0, institution: institutionJSON)
        let student = try! Student.persistenceAdd(json: studentJSON, container: container, context: persistentContainer.viewContext)
        print(student.debugDescription)
    }
}

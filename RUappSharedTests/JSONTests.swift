//
//  JSONTests.swift
//  RUappSharedTests
//
//  Created by Igor Camilo on 13/09/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

import XCTest
@testable import RUappShared

class JSONTests: XCTestCase {
    
    func testInstitution() {
        let institution: JSONInstitution = try! decodedMockData(name: "Institution")
        XCTAssert(institution.id == "1", "ID doesn't match")
    }
    
    func testMenu() {
        let menu: [JSONMenu] = try! decodedMockData(name: "Menu")
        XCTAssert(menu.count == 7, "Count doesn't match")
    }
    
    func testResult() {
        let result: JSONResult = try! decodedMockData(name: "Result")
        XCTAssert(result.mealName == "Almoço", "Meal name doesn't match")
    }
    
    func testRegisterStudent() {
        let registeredStudent: JSONRegisteredStudent = try! decodedMockData(name: "RegisterStudent")
        XCTAssert(registeredStudent.studentId == 1289, "Student ID doesn't match")
    }
}

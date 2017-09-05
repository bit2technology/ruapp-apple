//
//  TestVote.swift
//  RUapp
//
//  Created by Igor Camilo on 15-11-06.
//  Copyright © 2015 Igor Camilo. All rights reserved.
//

import XCTest
@testable import RUappService

class TestVote: XCTestCase {
    
    func testVoteSingle() {
        
        let exp = expectation(description: "institutionList")
        
        Institution.getList { (list, error) -> Void in
            
            XCTAssertNil(error, "Error downloading list")
            XCTAssertNotNil(list, "Institution list cannot be nil")
            XCTAssertNotNil(list?.first, "Institution list cannot be empty")
            
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testInstitution() {
        
        let exp = expectation(description: "institution")
        
        Institution.get(1) { (institution, error) -> Void in
            
            XCTAssertNil(error, "Error must be nil")
            XCTAssertNotNil(institution, "Institution cannot be nil")
            
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testRegister() {
        
        let exp = expectation(description: "register")
        
        Institution.getList { (list, error) -> Void in
            
            XCTAssertNil(error, "Error downloading list")
            XCTAssertNotNil(list, "Institution list cannot be nil")
            XCTAssertNotNil(list?.first, "Institution list cannot be empty")
            list?.first?.registerWithNewStudent("Igor Camilo", studentInstitutionId: "iOSTestCase", completion: { (student, institution, error) -> Void in
                
                XCTAssertNil(error, "Error must be nil")
                XCTAssertNotNil(student, "Student cannot be nil")
                XCTAssertNotNil(institution, "Institution cannot be nil")
                
                exp.fulfill()
            })
        }
        
        waitForExpectations(timeout: 20, handler: nil)
    }
}

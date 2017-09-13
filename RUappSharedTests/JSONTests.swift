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
    
    private func decodedMockData<T: Decodable>(name: String) throws -> T {
        let url = Bundle(for: JSONTests.self).url(forResource: name, withExtension: "json")!
        return try JSONDecoder().decode(T.self, from: Data(contentsOf: url))
    }
    
    func testMenu() {
        let menu: [JSONMenu] = try! decodedMockData(name: "Menu")
        XCTAssert(menu.count == 7, "Menu count doesn't match")
    }
}

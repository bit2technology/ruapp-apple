//
//  Helpers.swift
//  RUapp
//
//  Created by Igor Camilo on 18/09/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

import Foundation
@testable import RUappShared

func decodedMockData<T: Decodable>(name: String) throws -> T {
    let url = Bundle(for: JSONTests.self).url(forResource: name, withExtension: "json")!
    return try JSONDecoder().decode(T.self, from: Data(contentsOf: url))
}

let persistentContainer = try! PersistentContainer(directoryURL: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!)

//
//  DataOperationStub.swift
//  RUappSharedTests
//
//  Created by Igor Camilo on 18/02/18.
//  Copyright © 2018 Bit2 Technology. All rights reserved.
//

import Foundation
@testable import RUappShared

class DataOperationStub: AsyncOperation {
    
    let url: URL
    
    init(url: URL) {
        self.url = url
        super.init()
    }
    
    override func main() {
        finish()
    }
}

extension DataOperationStub: DataOperationProtocol {
    
    func data() throws -> Data {
        print("URL!!!!!", url)
        return try Data(contentsOf: url)
    }
}

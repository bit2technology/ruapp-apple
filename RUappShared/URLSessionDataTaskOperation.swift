//
//  URLSessionDataTaskOperation.swift
//  RUappShared
//
//  Created by Igor Camilo on 18/02/18.
//  Copyright © 2018 Bit2 Technology. All rights reserved.
//

import Foundation

protocol DataOperationProtocol where Self: Operation {
    
    func data() throws -> Data
}

class URLSessionDataTaskOperation: AsyncOperation {
    
    var request: URLRequest? {
        didSet {
            assert(task == nil, "Task can't be running or finished when changing the request!")
        }
    }
    
    private var task: URLSessionDataTask?
    private var downloadedData: Data?
    
    init(request: URLRequest?) {
        self.request = request
        super.init()
    }
    
    override func cancel() {
        super.cancel()
        task?.cancel()
    }
    
    override func main() {
        guard let request = request else {
            finish(error: URLSessionDataTaskOperationError.noRequest)
            return
        }
        task = URLSession.shared.dataTask(with: request) {
            if !self.isCancelled {
                if let error = $2 {
                    self.finish(error: error)
                } else if let data = $0 {
                    self.downloadedData = data
                    self.finish()
                } else {
                    self.finish(error: URLSessionDataTaskOperationError.noData)
                }
            }
        }
        task!.resume()
    }
}

extension URLSessionDataTaskOperation: DataOperationProtocol {
    
    func data() throws -> Data {
        if let error = error {
            throw error
        } else if let data = downloadedData {
            return data
        } else {
            throw URLSessionDataTaskOperationError.noData
        }
    }
}

public enum URLSessionDataTaskOperationError: Error {
    case noRequest
    case noData
}

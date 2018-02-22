//
//  URLSessionDataTaskOperation.swift
//  RUappShared
//
//  Created by Igor Camilo on 18/02/18.
//  Copyright © 2018 Bit2 Technology. All rights reserved.
//

import Foundation

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
    
    convenience init(url: URL?) {
        if let url = url {
            self.init(request: URLRequest(url: url))
        } else {
            self.init(request: nil)
        }
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
                } else if let code = ($1 as? HTTPURLResponse)?.statusCode, (400..<600).contains(code) {
                    self.finish(error: URLSessionDataTaskOperationError.statusCode(code))
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
    
    func data() throws -> Data {
        if let data = downloadedData {
            return data
        } else {
            throw error ?? URLSessionDataTaskOperationError.noData
        }
    }
}

public enum URLSessionDataTaskOperationError: Error {
    case noRequest
    case statusCode(Int)
    case noData
}

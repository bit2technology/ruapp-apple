//
//  URLSessionDataTaskOperation.swift
//  RUappShared
//
//  Created by Igor Camilo on 01/11/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

open class URLSessionDataTaskOperation: AsyncOperation<(data: Data?, response: URLResponse?, error: Error?)> {
    
    private let request: URLRequest
    private var task: URLSessionDataTask?
    
    private static let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "URLSessionDataTaskOperationQueue"
        return queue
    }()
    
    public init(request: URLRequest) {
        self.request = request
        super.init()
        URLSessionDataTaskOperation.queue.addOperation(self)
    }
    
    override open func main() {
        task = URLSession.shared.dataTask(with: request) {
            self.result = ($0, $1, $2)
        }
        task!.resume()
    }
    
    open func data() throws -> Data {
        assert(isFinished, "Operation must be finished to get result")
        guard let result = result else {
            throw Error.noResult
        }
        if let error = result.error {
            throw error
        }
        guard let data = result.data else {
            throw Error.noData
        }
        return data
    }
    
    public enum Error: Swift.Error {
        case noResult
        case noData
    }
}

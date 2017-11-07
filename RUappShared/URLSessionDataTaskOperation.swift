//
//  URLSessionDataTaskOperation.swift
//  RUappShared
//
//  Created by Igor Camilo on 01/11/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

open class URLSessionDataTaskOperation: AsyncOperation {
    
    private let request: URLRequest
    private var task: URLSessionDataTask?
    private var taskResult: (data: Data?, response: URLResponse?, error: Error?)
    
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
    
    override open func start() {
        startExecution()
        task = URLSession.shared.dataTask(with: request) {
            self.taskResult = ($0, $1, $2)
            self.finishExecution()
        }
        task!.resume()
    }
    
    override open func cancel() {
        task?.cancel()
        finishExecution()
        super.cancel()
    }
    
    open func result() throws -> (data: Data, response: URLResponse) {
        assert(isFinished, "Operation must be finished to parse")
        if let error = taskResult.error {
            throw error
        }
        return (taskResult.data!, taskResult.response!)
    }
}

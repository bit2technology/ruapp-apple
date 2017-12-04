//
//  URLSessionDataTaskOperation.swift
//  Bit2Common
//
//  Created by Igor Camilo on 29/11/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

open class URLSessionDataTaskOperation: AdvancedOperation<Data> {
    
    /// Count how many `URLSessionDataTaskOperation`s are executing.
    public static var count = 0 {
        didSet {
            countObserver?(count)
        }
    }
    
    /// Execute closure every time `count` changes.
    public static var countObserver: ((_ count: Int) -> Void)? {
        didSet {
            countObserver?(count)
        }
    }
    
    private let request: URLRequest
    private var task: URLSessionDataTask?
    
    public init(request: URLRequest) {
        self.request = request
        super.init()
    }
    
    open override func cancel() {
        super.cancel()
        task?.cancel()
    }
    
    open override func main() {
        URLSessionDataTaskOperation.count += 1
        task = URLSession.shared.dataTask(with: request) {
            if !self.isCancelled {
                if let error = $2 {
                    self.finish(error: error)
                } else if let data = $0 {
                    self.finish(value: data)
                } else {
                    self.finish(error: URLSessionDataTaskOperationError.noData)
                }
            }
            URLSessionDataTaskOperation.count -= 1
        }
        task!.resume()
    }
}

public enum URLSessionDataTaskOperationError: Error {
    case noData
}

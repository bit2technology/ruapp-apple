//
//  URLSessionDataTaskOperation.swift
//  RUappShared
//
//  Created by Igor Camilo on 01/11/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

public class URLSessionDataTaskOperation: AsyncOperation<Data> {
    
    /// Count how many `URLSessionDataTaskOperation`s are executing.
    public static var count = 0 {
        didSet {
            countObserver?(count)
        }
    }
    
    /// Execute closure every time `count` changes.
    public static var countObserver: ((_ count: Int) -> Void)?
    
    private let request: URLRequest
    private var task: URLSessionDataTask?
    
    init(request: URLRequest) {
        self.request = request
        super.init()
    }
    
    public override func cancel() {
        super.cancel()
        task?.cancel()
    }
    
    public override func main() {
        URLSessionDataTaskOperation.count += 1
        task = URLSession.shared.dataTask(with: request) {
            if !self.isCancelled {
                self.result = ($0, $2)
            }
            URLSessionDataTaskOperation.count -= 1
        }
        task!.resume()
    }
}

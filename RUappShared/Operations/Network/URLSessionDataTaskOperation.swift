//
//  URLSessionDataTaskOperation.swift
//  RUappShared
//
//  Created by Igor Camilo on 01/11/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

open class URLSessionDataTaskOperation: AsyncOperation<Data> {
    
    public static var count = 0 {
        didSet {
            countObserver?(count)
        }
    }
    public static var countObserver: ((_ count: Int) -> Void)?
    
    private let request: URLRequest
    private var task: URLSessionDataTask?
    
    public init(request: URLRequest) {
        self.request = request
        super.init()
    }
    
    override open func main() {
        URLSessionDataTaskOperation.count += 1
        task = URLSession.shared.dataTask(with: request) {
            self.result = ($0, $2)
            URLSessionDataTaskOperation.count -= 1
        }
        task!.resume()
    }
}

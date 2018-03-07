//
//  URLSessionDataTaskOperation.swift
//  RUappShared
//
//  Created by Igor Camilo on 18/02/18.
//  Copyright © 2018 Bit2 Technology. All rights reserved.
//

import Foundation

public final class URLSessionDataTaskOperation: AsyncOperation<Data> {

  public var request: URLRequest? {
    didSet {
      assert(task == nil, "Task can't be running or finished when changing the request!")
    }
  }

  public var session: URLSession? {
    didSet {
      assert(task == nil, "Task can't be running or finished when changing the session!")
    }
  }

  private var task: URLSessionDataTask?

  public init(request: URLRequest? = nil, session: URLSession? = nil) {
    self.request = request
    self.session = session
    super.init()
  }

  public override func cancel() {
    super.cancel()
    task?.cancel()
  }

  public override func main() {
    guard let request = request else {
      finish(error: URLSessionDataTaskOperationError.noRequest)
      return
    }
    task = (session ?? .shared).dataTask(with: request) {
      if !self.isCancelled {
        if let error = $2 {
          self.finish(error: error)
        } else if let code = ($1 as? HTTPURLResponse)?.statusCode, (400..<600).contains(code) {
          self.finish(error: URLSessionDataTaskOperationError.statusCode(code))
        } else if let data = $0 {
          self.finish(data)
        } else {
          self.finish(error: URLSessionDataTaskOperationError.noData)
        }
      }
    }
    task!.resume()
  }
}

extension URLSessionDataTaskOperation {
  convenience init(url: URL?) {
    if let url = url {
      self.init(request: URLRequest(url: url))
    } else {
      self.init(request: nil)
    }
  }
}

public enum URLSessionDataTaskOperationError: Error {
  case noRequest
  case statusCode(Int)
  case noData
}

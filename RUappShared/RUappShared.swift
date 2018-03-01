//
//  RUappShared.swift
//  RUappShared
//
//  Created by Igor Camilo on 09/01/18.
//  Copyright © 2018 Bit2 Technology. All rights reserved.
//

import Foundation
import CoreData
import PromiseKit

public extension OperationQueue {
  static let async: OperationQueue = {
    let queue = OperationQueue()
    queue.name = "AsyncOperationQueue"
    return queue
  }()
}

public extension Array {
  func orderedSet() -> NSOrderedSet {
    return NSOrderedSet(array: self)
  }
}

public extension UserDefaults {
  public static let shared = UserDefaults(suiteName: "group.technology.bit2.ruapp")!
}

public extension URLResponse {
  public func validateHTTPStatusCode() throws {
    guard let statusCode = (self as? HTTPURLResponse)?.statusCode else {
      return
    }
    if (400..<600).contains(statusCode) {
      throw URLResponseError.httpStatusCodeError(statusCode)
    }
  }
}

public enum URLResponseError: Error {
  case httpStatusCodeError(Int)
}

extension NSManagedObjectContext {

  func mergingObjects() -> NSManagedObjectContext {
    self.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    return self
  }

  func performAndWait<T>(_ block: () -> T) -> T {
    var t: T!
    performAndWait {
      t = block()
    }
    return t
  }

  func performPromise<T>(block: @escaping () throws -> T) -> Promise<T> {
    return Promise<T> { resolver in
      perform {
        do {
          resolver.fulfill(try block())
        } catch {
          resolver.reject(error)
        }
      }
    }
  }
}

//
//  AsyncOperation.swift
//  RUappShared
//
//  Created by Igor Camilo on 08/02/18.
//  Copyright © 2018 Bit2 Technology. All rights reserved.
//

import Foundation

public extension OperationQueue {
  static let async: OperationQueue = {
    let queue = OperationQueue()
    queue.name = "AsyncOperationQueue"
    return queue
  }()
}

open class AsyncOperation<T>: Operation {

  override open var isExecuting: Bool {
    return state == .executing
  }

  override open var isFinished: Bool {
    return state == .finished || isCancelled
  }

  private var _result = Result<T>.failure(AsyncOperationError.notFinished)
  private var _state = OperationState.initialized
  private let stateLock = NSLock()

  open var queue: OperationQueue { return .async }
  open var dependenciesToAdd: [Operation] { return [] }

  public override init() {
    super.init()
    dependenciesToAdd.forEach { addDependency($0) }
    queue.addOperation(self)
  }

  override open func start() {
    guard !isCancelled else {
      return
    }
    assert(state == .initialized, "Operation must not be finished to execute")
    state = .executing
    main()
  }
}

// MARK: Result

extension AsyncOperation {

  public func finish(_ value: T) {
    finish(result: .success(value))
  }

  public func finish(error: Error) {
    finish(result: .failure(error))
  }

  private func finish(result: Result<T>) {
    _result = result
    state = .finished
  }

  public func result() throws -> T {
    switch _result {
    case .success(let value):
      return value
    case .failure(let error):
      throw error
    }
  }
}

private enum Result<T> {
  case success(T)
  case failure(Error)
}

// MARK: State

extension AsyncOperation {
  private var state: OperationState {
    get {
      stateLock.lock()
      let state = _state
      stateLock.unlock()
      return state
    }
    set {
      let affectedKeyPaths = state.affectedKeyPaths(whenChangedTo: newValue)
      affectedKeyPaths.forEach { willChangeValue(forKey: $0) }
      stateLock.lock()
      _state = newValue
      stateLock.unlock()
      affectedKeyPaths.forEach { didChangeValue(forKey: $0) }
    }
  }
}

private enum OperationState {
  case initialized
  case executing
  case finished

  func affectedKeyPaths(whenChangedTo state: OperationState) -> [String] {
    switch (self, state) {
    case (.initialized, .executing):
      return ["isExecuting"]
    case (.initialized, .finished):
      return ["isFinished"]
    case (.executing, .finished):
      return ["isExecuting", "isFinished"]
    default:
      fatalError("State transition not allowed: \(self) to \(state)")
    }
  }
}

// MARK: Error

public enum AsyncOperationError: Error {
  case notFinished
}

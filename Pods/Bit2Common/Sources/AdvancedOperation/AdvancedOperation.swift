//
//  AdvancedOperation.swift
//  Bit2Common
//
//  Created by Igor Camilo on 27/11/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

/// Base class for operations, with support for asynchronous activity.
open class AdvancedOperation<Value>: Operation {
    
    open override var isExecuting: Bool {
        return state == .executing
    }
    
    open override var isFinished: Bool {
        return state == .finished
    }
    
    /// Default queue.
    open var queue: OperationQueue {
        return .async
    }
    
    /// Dependencies to be added on `init()`.
    open var dependenciesToAdd: [Operation] {
        return []
    }
    
    private var result: (value: Value?, error: Error?)
    
    /// Track the state of this opereation.
    private var state = State.initialized
    
    /// Initialize the operation, add dependencies from `dependenciesToAdd` and add to `queue`.
    public override init() {
        super.init()
        dependenciesToAdd.forEach(addDependency)
        queue.addOperation(self)
    }
    
    open override func start() {
        guard !isCancelled else {
            return
        }
        assert(state == .initialized, "Operation must not be finished to execute")
        // Update state and send KVO notifications
        let affectedKeyPaths = ["isExecuting"]
        affectedKeyPaths.forEach {
            willChangeValue(forKey: $0)
        }
        state = .executing
        affectedKeyPaths.forEach {
            didChangeValue(forKey: $0)
        }
        // Call main() to perform custom subclass code
        main()
    }
    
    open override func cancel() {
        super.cancel()
        finish(error: AdvancedOperationError.cancelled)
    }
    
    open func finish(value: Value) {
        finish(value: value, error: nil)
    }
    
    open func finish(error: Error) {
        finish(value: nil, error: error)
    }
    
    /// Retrieves value from `result`.
    ///
    /// - Returns: Value
    /// - Throws: `AsyncOperationError` and others
    open func value() throws -> Value {
        assert(isFinished, "Operation must be finished to get value")
        if let error = result.error {
            throw error
        }
        guard let value = result.value else {
            throw AdvancedOperationError.noValue
        }
        return value
    }
    
    private func finish(value: Value?, error: Error?) {
        result = (value, error)
        // Update state and send KVO notifications
        let affectedKeyPaths = ["isExecuting", "isFinished"]
        affectedKeyPaths.forEach {
            willChangeValue(forKey: $0)
        }
        state = .finished
        affectedKeyPaths.forEach {
            didChangeValue(forKey: $0)
        }
    }
    
    private enum State {
        case initialized
        case executing
        case finished
    }
}

public enum AdvancedOperationError: Error {
    case cancelled
    case noValue
}

private extension OperationQueue {
    static let async: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "AsyncOperationQueue"
        return queue
    }()
}

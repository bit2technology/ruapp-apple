//
//  AsyncOperation.swift
//  RUappShared
//
//  Created by Igor Camilo on 01/11/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

/// Base class for asynchronous operations.
public class AsyncOperation<Value>: Operation {
    
    /// Stores the result and an possible error. Retrieve value from `value()` method.
    var result: (value: Value?, error: Error?) {
        didSet {
            finishExecution()
        }
    }
    
    public override var isExecuting: Bool {
        return state == .executing
    }
    
    public override var isFinished: Bool {
        return state == .finished
    }
    
    public override var isAsynchronous: Bool {
        return true
    }
    
    /// Default queue.
    var queue: OperationQueue {
        return .async
    }
    
    /// Dependencies to be added on `init()`.
    var dependenciesToAdd: [Operation] {
        return []
    }
    
    /// Track the state of this opereation.
    private var state = State.initialized
    
    /// Initialize the operation, add dependencies from `dependenciesToAdd` and add to `queue`.
    public override init() {
        super.init()
        dependenciesToAdd.forEach(addDependency)
        queue.addOperation(self)
    }
    
    public override func start() {
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
    
    public override func cancel() {
        super.cancel()
        result = (nil, AsyncOperationError.cancelled)
    }
    
    /// Retrieves value from `result`.
    ///
    /// - Returns: Value
    /// - Throws: `AsyncOperationError` and others
    func value() throws -> Value {
        assert(isFinished, "Operation must be finished to get value")
        if let error = result.error {
            throw error
        }
        guard let value = result.value else {
            throw AsyncOperationError.noValue
        }
        return value
    }
    
    /// Called when `result` is set. This sends the appropriate KVO notifications.
    private func finishExecution() {
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

public enum AsyncOperationError: Error {
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

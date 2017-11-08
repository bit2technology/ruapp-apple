//
//  AsyncOperation.swift
//  RUappShared
//
//  Created by Igor Camilo on 01/11/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

private let privateQueue: OperationQueue = {
    let queue = OperationQueue()
    queue.name = "AsyncOperationQueue"
    return queue
}()

open class AsyncOperation<Value>: Operation {
    
    var result: (value: Value?, error: Error?) {
        didSet {
            finishExecution()
        }
    }
    
    override open var isExecuting: Bool {
        return state == .executing
    }
    
    override open var isFinished: Bool {
        return state == .finished
    }
    
    override open var isAsynchronous: Bool {
        return true
    }
    
    open var queue: OperationQueue {
        return privateQueue
    }
    
    open var dependenciesToAdd: [Operation] {
        return []
    }
    
    private var state = State.initialized
    
    public override init() {
        super.init()
        dependenciesToAdd.forEach(addDependency)
        queue.addOperation(self)
    }
    
    override open func start() {
        guard !isCancelled else {
            return
        }
        assert(state == .initialized, "Operation must not be finished to execute")
        let affectedKeyPaths = ["isExecuting"]
        affectedKeyPaths.forEach {
            willChangeValue(forKey: $0)
        }
        state = .executing
        affectedKeyPaths.forEach {
            didChangeValue(forKey: $0)
        }
        main()
    }
    
    open func value() throws -> Value {
        assert(isFinished, "Operation must be finished to get value")
        if let error = result.error {
            throw error
        }
        guard let value = result.value else {
            throw AsyncOperationError.noValue
        }
        return value
    }
    
    private func finishExecution() {
        assert(state == .executing || isCancelled, "Operation must be executing or cancelled to finish")
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
    case noValue
}

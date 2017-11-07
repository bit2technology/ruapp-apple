//
//  AsyncOperation.swift
//  RUappShared
//
//  Created by Igor Camilo on 01/11/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

open class AsyncOperation<Result>: Operation {
    
    var result: Result? {
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
    
    private var state = State.initialized
    
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

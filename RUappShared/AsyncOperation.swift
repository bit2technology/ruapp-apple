//
//  AsyncOperation.swift
//  RUappShared
//
//  Created by Igor Camilo on 08/02/18.
//  Copyright © 2018 Bit2 Technology. All rights reserved.
//

import Foundation

public class AsyncOperation: Operation {
    
    override public var isExecuting: Bool {
        return state == .executing
    }
    
    override public var isFinished: Bool {
        return state == .finished || isCancelled
    }
    
    private(set) var error: Error?
    
    private var state = State.initialized {
        willSet {
            state.affectedKeyPaths(whenChangedTo: newValue).forEach { willChangeValue(forKey: $0) }
        }
        didSet {
            oldValue.affectedKeyPaths(whenChangedTo: state).forEach { didChangeValue(forKey: $0) }
        }
    }
    
    override public func start() {
        guard !isCancelled else {
            return
        }
        assert(state == .initialized, "Operation must not be finished to execute")
        state = .executing
        main()
    }
    
    func finish(error: Error? = nil) {
        self.error = error
        state = .finished
    }
    
    private enum State {
        case initialized
        case executing
        case finished
        
        func affectedKeyPaths(whenChangedTo state: State) -> [String] {
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
}

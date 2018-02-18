//
//  AsyncOperation.swift
//  RUappShared
//
//  Created by Igor Camilo on 08/02/18.
//  Copyright © 2018 Bit2 Technology. All rights reserved.
//

import Foundation

class AsyncOperation: Operation {
    
    override var isExecuting: Bool {
        return state == .executing
    }
    
    override var isFinished: Bool {
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
    
    override func start() {
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
    
    func allErrors() -> [Error] {
        let dependenciesErrors = dependencies.flatMap { $0 as? AsyncOperation }.reduce([]) { $0 + $1.allErrors() }
        if let error = error {
            return [error] + dependenciesErrors
        } else {
            return dependenciesErrors
        }
    }
    
    private enum State {
        case initialized
        case executing
        case finished
        
        func affectedKeyPaths(whenChangedTo state: State) -> [String] {
            switch (self, state) {
            case (.initialized, .executing):
                return ["isExecuting"]
            case (.executing, .finished):
                return ["isExecuting", "isFinished"]
            default:
                fatalError("State transition not allowed: \(self) to \(state)")
            }
        }
    }
}

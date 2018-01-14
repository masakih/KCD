//
//  Future.swift
//  KCD
//
//  Created by Hori,Masaki on 2018/01/13.
//  Copyright © 2018年 Hori,Masaki. All rights reserved.
//

import Foundation


enum Result<T> {
    
    case value(T)
    case none
    case error(Error)
}

let watingQueue = DispatchQueue(label: "Future", attributes: .concurrent)
class Future<T> {
    
    private let queue: DispatchQueue
    private let semaphore = DispatchSemaphore(value: 1)
    
    private var result: Result<T> = .none
    
    init(queue: DispatchQueue = watingQueue) {
        
        self.queue = queue
        
        self.semaphore.wait()
    }
    deinit {
        semaphore.signal()
    }
    
    @discardableResult
    func onSuccess(block: @escaping (T) -> Void) -> Future<T> {
        
        queue.async {
            
            self.semaphore.wait()
            if case .value(let value) = self.result { block(value) }
            self.semaphore.signal()
        }
        
        return self
    }
    
    @discardableResult
    func onFailure(block: @escaping (Error) -> Void) -> Future<T> {
        
        queue.async {
            
            self.semaphore.wait()
            if case .error(let error) = self.result { block(error) }
            self.semaphore.signal()
        }
        
        return self
    }
    
    func success(_ value: T) {
        
        switch result {
            
        case .value, .error:
            Logger.shared.log("multi call success(_:)")
            fatalError()
            
        case .none:
            result = .value(value)
            semaphore.signal()
        }
    }
    
    func failure(_ error: Error) {
        
        switch result {
            
        case .value, .error:
            Logger.shared.log("multi call failure(_:)")
            fatalError()
            
        case .none:
            result = .error(error)
            semaphore.signal()
        }
        
    }
}

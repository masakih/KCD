//
//  Future.swift
//  KCD
//
//  Created by Hori,Masaki on 2018/01/13.
//  Copyright © 2018年 Hori,Masaki. All rights reserved.
//

import Foundation

let watingQueue = DispatchQueue(label: "Future")
class Future<T> {
    
    private let queue: DispatchQueue
    private let semaphore = DispatchSemaphore(value: 1)
    
    private(set) var value: T?
    private(set) var error: Error?
    
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
            self.value.map(block)
            self.semaphore.signal()
        }
        
        return self
    }
    
    @discardableResult
    func onFailure(block: @escaping (Error) -> Void) -> Future<T> {
        
        queue.async {
            
            self.semaphore.wait()
            self.error.map(block)
            self.semaphore.signal()
        }
        
        return self
    }
    
    func success(_ value: T) {
        
        guard self.value == nil else { return }
        guard self.error == nil else { return }
        
        self.value = value
        semaphore.signal()
    }
    
    func failure(_ error: Error) {
        
        guard self.value == nil else { return }
        guard self.error == nil else { return }
        
        self.error = error
        semaphore.signal()
    }
}

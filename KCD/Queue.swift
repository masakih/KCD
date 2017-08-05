//
//  Queue.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/06.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class Queue<T> {
    
    private var contents: [T] = []
    private let lock = NSCondition()
    
    func dequeue() -> T {
        
        lock.lock()
        defer { lock.unlock() }
        
        while contents.count == 0 {
            
            lock.wait()
        }
        
        return contents.popLast()!
    }
    
    func enqueue(_ obj: T) {
        
        lock.lock()
        defer { lock.unlock() }
        
        contents.insert(obj, at: 0)
        
        lock.broadcast()
    }
}

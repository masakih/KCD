//
//  Queue.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/06.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

class Queue {
    private var contents: [Any] = []
    private let lock = NSCondition()
    
    func dequeue() -> Any {
        lock.lock()
        defer { lock.unlock() }
        while contents.count == 0 {
            lock.wait()
        }
        return contents.popLast()!
    }
    func enqueue(_ obj: Any) {
        lock.lock()
        defer { lock.unlock() }
        contents.insert(obj, at: 0)
        lock.broadcast()
    }
}

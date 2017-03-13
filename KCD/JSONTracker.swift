//
//  JSONTracker.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/21.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

class JSONTracker {
    private let queue: Queue
    private let reciever: JSONReciever
    
    init() {
        queue = Queue()
        reciever = JSONReciever(queue: queue)
        start()
    }
    deinit {
        print("DEINIT")
    }
    
    private func doAction() {
        guard let item = queue.dequeue() as? APIResponse
            else { return print("Dequeued item is not APIResponse") }
        do {
            try CommandRegister.command(for: item).execute()
        } catch {
            print("JSONTracker Cought Exception -> \(error)")
        }
    }
    
    private func start() {
        DispatchQueue(label: "JSONTracker")
            .async { while true { autoreleasepool { self.doAction() } } }
    }
}

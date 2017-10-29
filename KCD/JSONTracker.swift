//
//  JSONTracker.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/21.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class JSONTracker {
    
    private let queue: Queue<APIResponse>
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
        
        do {
            
            try CommandRegister.command(for: queue.dequeue()).execute()
            
        } catch {
            
            print("JSONTracker Cought Exception -> \(error)")
        }
    }
    
    private func start() {
        
        DispatchQueue(label: "JSONTracker")
            .async { while true { autoreleasepool { self.doAction() } } }
    }
}

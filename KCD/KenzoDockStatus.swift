//
//  KenzoDockStatus.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/22.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

fileprivate enum DockState: Int {
    case empty = 0
    case hasShip = 2
    case completed = 3
    case notOpen = -1
}

class KenzoDockStatus: NSObject {
    private let number: Int
    private let controller: NSArrayController
    private var isTasking = false
    private var didNotify = false
    private var realTime: TimeInterval = 0.0 {
        didSet { time = realTime as NSNumber }
    }
    dynamic var time: NSNumber?
    dynamic var state: NSNumber? {
        didSet {
            guard let s = DockState(rawValue: state as! Int)
                else { return print("unknown State") }
            switch s {
            case .empty, .notOpen:
                isTasking = false
                didNotify = false
            case .hasShip, .completed:
                isTasking = true
            }
        }
    }
    
    init?(number: Int) {
        guard 1...4 ~= number else { return nil }
        self.number = number
        controller = NSArrayController()
        super.init()
        controller.managedObjectContext = ServerDataStore.default.managedObjectContext
        controller.entityName = Entity.kenzoDock.name
        controller.fetchPredicate = NSPredicate(format: "id = %ld", number)
        controller.automaticallyRearrangesObjects = true
        controller.fetch(nil)
        
        bind("state", to: controller, withKeyPath: "selection.state")
    }
    
    func update() {
        if !isTasking {
            time = nil
            return
        }
        guard let t = controller.value(forKeyPath: "selection.complete_time") as? Int
            else {
                time = nil
                return
        }
        let compTime = TimeInterval(Int(t / 1_000))
        let now = Date()
        let diff = compTime - now.timeIntervalSince1970
        
        if diff < 0 { realTime = 0 }
        else { realTime = diff }
        
        if didNotify { return }
        if diff > 0 { return }
        
        let notification = NSUserNotification()
        let format = NSLocalizedString("It Will Finish Build at No.%@.", comment: "It Will Finish Build at No.%@.")
        notification.title = String(format: format, number as NSNumber)
        notification.informativeText = notification.title
        if UserDefaults.standard.playFinishKenzoSound {
            notification.soundName = NSUserNotificationDefaultSoundName
        }
        NSUserNotificationCenter.default.deliver(notification)
        didNotify = true
    }
    
}

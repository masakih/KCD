//
//  KenzoDockStatus.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/22.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

private enum DockState: Int {
    
    case empty = 0
    case hasShip = 2
    case completed = 3
    case notOpen = -1
}

final class KenzoDockStatus: NSObject {
    
    private let number: Int
    private let controller = NSArrayController()
    private var isTasking = false
    private var didNotify = false
    private var realTime: TimeInterval = 0.0 {
        
        didSet { time = realTime as NSNumber }
    }
    
    @objc dynamic var time: NSNumber?
    @objc dynamic var state: NSNumber? {
        
        didSet { updateState() }
    }
    @objc dynamic var completeTime: NSNumber?
    
    init?(number: Int) {
        
        guard case 1...4 = number else { return nil }
        
        self.number = number
        
        super.init()
        
        controller.managedObjectContext = ServerDataStore.default.context
        controller.entityName = KenzoDock.entityName
        controller.fetchPredicate = NSPredicate(#keyPath(KenzoDock.id), equal: number)
        controller.automaticallyRearrangesObjects = true
        controller.fetch(nil)
        
        bind(NSBindingName(#keyPath(state)), to: controller, withKeyPath: "selection.state")
        bind(NSBindingName(#keyPath(completeTime)), to: controller, withKeyPath: "selection.complete_time")
    }
    
    private func updateState() {
        
        guard let state = state as? Int,
            let s = DockState(rawValue: state) else {
                
                print("unknown State")
                return
        }
        
        switch s {
        case .empty, .notOpen:
            isTasking = false
            didNotify = false
            
        case .hasShip, .completed:
            isTasking = true
        }
    }
    
    func update() {
        
        if !isTasking {
            
            time = nil
            return
        }
        guard let completeTime = completeTime as? Int else {
            
            time = nil
            return
        }
        
        let compTime = TimeInterval(Int(completeTime / 1_000))
        let diff = compTime - Date().timeIntervalSince1970
        
        realTime = diff < 0 ? 0 : diff
        
        if didNotify { return }
        if diff > 0 { return }
        
        let notification = NSUserNotification()
        let format = LocalizedStrings.buildingWillFinish.string
        notification.title = String(format: format, number as NSNumber)
        notification.informativeText = notification.title
        
        if UserDefaults.standard[.playFinishKenzoSound] {
            
            notification.soundName = NSUserNotificationDefaultSoundName
        }
        
        NSUserNotificationCenter.default.deliver(notification)
        
        didNotify = true
    }
    
}

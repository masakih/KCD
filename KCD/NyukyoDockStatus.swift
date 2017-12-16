//
//  NyukyoDockStatus.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/23.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

private enum DockState: Int {
    
    case empty = 0
    case hasShip = 1
}

final class NyukyoDockStatus: NSObject {
    
    private let number: Int
    private let controller = NSArrayController()
    private var didNotify = false
    private var realTime: TimeInterval = 0.0 {
        
        didSet { time = realTime as NSNumber }
    }
    
    @objc dynamic var name: String?
    @objc dynamic var time: NSNumber?
    @objc dynamic var state: NSNumber? {
        
        didSet { updateState() }
    }
    @objc dynamic var shipId: NSNumber? {
        
        didSet { updateState() }
    }
    @objc dynamic var completeTime: NSNumber?
    
    init?(number: Int) {
        
        guard case 1...4 = number else { return nil }
        
        self.number = number
        
        super.init()
        
        controller.managedObjectContext = ServerDataStore.default.context
        controller.entityName = NyukyoDock.entityName
        controller.fetchPredicate = NSPredicate(#keyPath(NyukyoDock.id), equal: number)
        controller.automaticallyRearrangesObjects = true
        controller.fetch(nil)
        
        bind(NSBindingName(#keyPath(state)), to: controller, withKeyPath: "selection.state")
        bind(NSBindingName(#keyPath(shipId)), to: controller, withKeyPath: "selection.ship_id")
        bind(NSBindingName(#keyPath(completeTime)), to: controller, withKeyPath: "selection.complete_time")
    }
    
    deinit {
        
        unbind(NSBindingName(#keyPath(state)))
        unbind(NSBindingName(#keyPath(shipId)))
        unbind(NSBindingName(#keyPath(completeTime)))
    }
    
    private func invalidate() {
        
        name = nil
        time = nil
    }
    
    private func updateState() {
        
        guard let state = state as? Int,
            let stat = DockState(rawValue: state) else {
                
                return Logger.shared.log("unknown State")
        }
        
        if stat == .empty {
            
            didNotify = false
            invalidate()
            return
        }
        
        guard let shipId = shipId as? Int, shipId != 0 else { return }
        
        guard let ship = ServerDataStore.default.ship(by: shipId) else {
            
            name = "Unknown"
            DispatchQueue(label: "NyukyoDockStatus").asyncAfter(deadline: .now() + 0.33) {
                
                self.updateState()
            }
            return
        }
        
        name = ship.name
    }
    
    func update() {
        
        guard let name = name else {
            
            time = nil
            return
        }
        
        guard let completeTime = completeTime as? Int else {
            
            invalidate()
            return
        }
        
        let compTime = TimeInterval(Int(completeTime / 1_000))
        let diff = compTime - Date().timeIntervalSince1970
        
        realTime = max(0, diff)
        
        if didNotify { return }
        if diff >= 1 * 60 { return }
        
        let notification = NSUserNotification()
        let format = LocalizedStrings.dockingWillFinish.string
        notification.title = String(format: format, name)
        notification.informativeText = notification.title
        
        if UserDefaults.standard[.playFinishNyukyoSound] {
            
            notification.soundName = NSUserNotificationDefaultSoundName
        }
        
        NSUserNotificationCenter.default.deliver(notification)
        
        didNotify = true
    }
}

//
//  NyukyoDockStatus.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/23.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

fileprivate enum DockState: Int {
    case empty = 0
    case hasShip = 1
}

class NyukyoDockStatus: NSObject {
    private let number: Int
    private let controller: NSArrayController
    private var didNotify = false
    private var realTime: TimeInterval = 0.0 {
        didSet { time = realTime as NSNumber }
    }
    dynamic var name: String?
    dynamic var time: NSNumber?
    dynamic var state: NSNumber? {
        didSet { updateState() }
    }
    
    init?(number: Int) {
        guard 1...4 ~= number else { return nil }
        self.number = number
        controller = NSArrayController()
        super.init()
        controller.managedObjectContext = ServerDataStore.default.managedObjectContext
        controller.entityName = NyukyoDock.entityName
        controller.fetchPredicate = NSPredicate(format: "id = %ld", number)
        controller.automaticallyRearrangesObjects = true
        controller.fetch(nil)
        
        bind("state", to: controller, withKeyPath: "selection.state")
    }
    
    private func updateState() {
        guard let state = state as? Int,
            let stat = DockState(rawValue: state)
            else { return print("unknown State") }
        if stat == .empty {
            didNotify = false
            name = nil
            time = nil
            return
        }
        
        guard let si = controller.value(forKeyPath: "selection.ship_id") as? Int,
            si != 0
            else { return }
        guard let ship = ServerDataStore.default.ship(byId: si)
            else {
                name = "Unknown"
                DispatchQueue(label: "NyukyoDockStatus")
                    .asyncAfter(deadline: .now() + 0.33) {
                        self.updateState()
                }
                return
        }
        name = ship.name
    }
    
    func update() {
        if name == nil {
            time = nil
            return
        }
        guard let t = controller.value(forKeyPath: "selection.complete_time") as? Int
            else {
                name = nil
                time = nil
                return
        }
        let compTime = TimeInterval(Int(t / 1_000))
        let now = Date()
        let diff = compTime - now.timeIntervalSince1970
        
        realTime = diff < 0 ? 0 : diff
        
        if didNotify { return }
        if diff >= 1 * 60 { return }
        
        let notification = NSUserNotification()
        let format = NSLocalizedString("%@ Will Finish Docking.", comment: "%@ Will Finish Docking.")
        notification.title = String(format: format, name!)
        notification.informativeText = notification.title
        if UserDefaults.standard.playFinishNyukyoSound {
            notification.soundName = NSUserNotificationDefaultSoundName
        }
        NSUserNotificationCenter.default.deliver(notification)
        didNotify = true
    }
}

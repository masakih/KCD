
//
//  MissionStatus.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/23.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

private enum State: Int {
    
    case none = 0
    case hasMission = 1
    case finish = 2
    case earlyReturn = 3
}

final class MissionStatus: NSObject {
    
    private let number: Int
    private let controller = NSArrayController()
    private var didNotify = false
    private var realTime: TimeInterval = 0.0 {
        
        didSet { time = realTime as NSNumber }
    }
    
    @objc dynamic var name: String?
    @objc dynamic var time: NSNumber?
    @objc dynamic var state: NSNumber?
    @objc dynamic var missionId: NSNumber? {
        
        didSet { updateState() }
    }
    @objc dynamic var milliseconds: NSNumber?
    @objc dynamic var fleetName: String?
    
    init?(number: Int) {
        
        guard case 2...4 = number else { return nil }
        
        self.number = number
        
        super.init()
        
        controller.managedObjectContext = ServerDataStore.default.context
        controller.entityName = Deck.entityName
        controller.fetchPredicate = NSPredicate(#keyPath(Deck.id), equal: number)
        controller.automaticallyRearrangesObjects = true
        controller.fetch(nil)
        
        bind(NSBindingName(#keyPath(state)), to: controller, withKeyPath: "selection.mission_0")
        bind(NSBindingName(#keyPath(missionId)), to: controller, withKeyPath: "selection.mission_1")
        bind(NSBindingName(#keyPath(milliseconds)), to: controller, withKeyPath: "selection.mission_2")
        bind(NSBindingName(#keyPath(fleetName)), to: controller, withKeyPath: "selection.name")
    }
    
    deinit {
        
        unbind(NSBindingName(#keyPath(state)))
        unbind(NSBindingName(#keyPath(missionId)))
        unbind(NSBindingName(#keyPath(milliseconds)))
        unbind(NSBindingName(#keyPath(fleetName)))
    }
    
    private func invalidate() {
        
        name = nil
        time = nil
    }
    
    private func updateState() {
        
        guard let state = state as? Int,
            let stat = State(rawValue: state) else {
                
                return Logger.shared.log("unknown State")
        }
        
        if stat == .none {
            
            didNotify = false
        }
        if stat == .none || stat == .finish {
            
            invalidate()
            return
        }
        
        guard let missionId = self.missionId as? Int else { return }
        
        guard let mission = ServerDataStore.default.masterMission(by: missionId) else {
            
            name = "Unknown"
            DispatchQueue(label: "MissionStatus").asyncAfter(deadline: .now() + 0.33) {
                
                self.updateState()
            }
            return
        }
        
        name = mission.name
    }
    
    func update() {
        
        if name == nil {
            
            time = nil
            return
        }
        
        guard let milliSeconds = milliseconds as? Int else {
            
            invalidate()
            return
        }
        
        let compTime = TimeInterval(Int(milliSeconds / 1_000))
        let diff = compTime - Date().timeIntervalSince1970
        
        realTime = max(0, diff)
        
        if didNotify { return }
        if diff >= 1 * 60 { return }
        
        guard let fleetName = fleetName else { return }
        
        let notification = NSUserNotification()
        let format = LocalizedStrings.missionWillReturnMessage.string
        notification.title = String(format: format, fleetName)
        let txtFormat = LocalizedStrings.missionWillReturnInformation.string
        notification.informativeText = String(format: txtFormat, fleetName, name!)
        
        if UserDefaults.standard[.playFinishMissionSound] {
            
            notification.soundName = NSUserNotificationDefaultSoundName
        }
        
        NSUserNotificationCenter.default.deliver(notification)
        
        didNotify = true
    }
}

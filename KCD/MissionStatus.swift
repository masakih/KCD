
//
//  MissionStatus.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/23.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

fileprivate enum State: Int {
    
    case none = 0
    case hasMission = 1
    case finish = 2
    case earlyReturn = 3
}

final class MissionStatus: NSObject {
    
    private let number: Int
    private let controller: NSArrayController
    private var didNotify = false
    private var realTime: TimeInterval = 0.0 {
        
        didSet { time = realTime as NSNumber }
    }
    
    dynamic var name: String?
    dynamic var time: NSNumber?
    dynamic var state: NSNumber?
    dynamic var missionId: NSNumber? {
        
        didSet { updateState() }
    }
    dynamic var milliseconds: NSNumber?
    dynamic var fleetName: String?
    
    init?(number: Int) {
        
        guard case 2...4 = number
            else { return nil }
        
        self.number = number
        controller = NSArrayController()
        
        super.init()
        
        controller.managedObjectContext = ServerDataStore.default.context
        controller.entityName = Deck.entityName
        controller.fetchPredicate = NSPredicate(format: "id = %ld", number)
        controller.automaticallyRearrangesObjects = true
        controller.fetch(nil)
        
        bind(#keyPath(state), to: controller, withKeyPath: "selection.mission_0")
        bind(#keyPath(missionId), to: controller, withKeyPath: "selection.mission_1")
        bind(#keyPath(milliseconds), to: controller, withKeyPath: "selection.mission_2")
        bind(#keyPath(fleetName), to: controller, withKeyPath: "selection.name")
    }
    
    deinit {
        
        unbind(#keyPath(state))
        unbind(#keyPath(missionId))
        unbind(#keyPath(milliseconds))
        unbind(#keyPath(fleetName))
    }
    
    private func updateState() {
        
        guard let state = state as? Int,
            let stat = State(rawValue: state)
            else { return print("unknown State") }
        
        if stat == .none || stat == .finish {
            
            if stat == .none { didNotify = false }
            
            name = nil
            time = nil
            
            return
        }
        
        guard let missionId = self.missionId as? Int
            else { return }
        
        guard let mission = ServerDataStore.default.masterMission(by: missionId)
            else {
                name = "Unknown"
                DispatchQueue(label: "MissionStatus")
                    .asyncAfter(deadline: .now() + 0.33) {
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
        
        guard let milliSeconds = milliseconds as? Int
            else {
                name = nil
                time = nil
                return
        }
        
        let compTime = TimeInterval(Int(milliSeconds / 1_000))
        let diff = compTime - Date().timeIntervalSince1970
        
        realTime = diff < 0 ? 0 : diff
        
        if didNotify { return }
        if diff >= 1 * 60 { return }
        
        guard let fleetName = fleetName
            else { return }
        
        let notification = NSUserNotification()
        let format = NSLocalizedString("%@ Will Return From Mission.", comment: "%@ Will Return From Mission.")
        notification.title = String(format: format, fleetName)
        let txtFormat = NSLocalizedString("%@ Will Return From %@.", comment: "%@ Will Return From %@.")
        notification.informativeText = String(format: txtFormat, fleetName, name!)
        
        if UserDefaults.standard[.playFinishMissionSound] {
            
            notification.soundName = NSUserNotificationDefaultSoundName
        }
        
        NSUserNotificationCenter.default.deliver(notification)
        
        didNotify = true
    }
}

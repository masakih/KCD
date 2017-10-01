//
//  GuardShelterCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/15.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa


enum GuardEscapeAPI: String {
    
    case goback = "/kcsapi/api_req_combined_battle/goback_port"
}

extension Notification.Name {
    
    static let DidUpdateGuardEscape = Notification.Name("com.masakih.KCD.Notification.DidUpdateGuardEscape")
}

final class GuardShelterCommand: JSONCommand {
    
    override class func canExecuteAPI(_ api: String) -> Bool {
        
        return GuardEscapeAPI(rawValue: api) != nil ? true : false
    }
    
    override func execute() {
        
        if let b = BattleAPI(rawValue: api) {
            
            switch b {
            case .battleResult, .combinedBattleResult:
                registerReserve()
                
            default:
                break
            }
        }
        if let m = MapAPI(rawValue: api), m == .next {
            
            removeInvalidEntry()
            
        }
        if let _ = GuardEscapeAPI(rawValue: api) {
            
            ensureGuardShelter()
            
        }
        if let _ = PortAPI(rawValue: api) {
            
            removeAllEntry()
            
        }
    }
    
    private func fleetMembers(fleetId: Int) -> [Int]? {
        
        guard let deck = ServerDataStore.default.deck(by: fleetId) else { return nil }
        
        return [deck.ship_0, deck.ship_1, deck.ship_2,
                deck.ship_3, deck.ship_4, deck.ship_5]
    }
    
    private func damagedShipId(damagedPos: Int) -> Int? {
        
        func fleetAndPos(_ pos: Int) -> ([Int]?, Int) {
            switch pos {
            case 1...6: return (fleetMembers(fleetId: 1), pos - 1)
                
            case 7...12: return (fleetMembers(fleetId: 2), pos - 6 - 1)
                
            default: return (nil, -1)
            }
        }
        
        let (fleet, pos) = fleetAndPos(damagedPos)
        
        return fleet?[pos]
    }
    
    private func registerReserve() {
        
        let escape = data["api_escape"]
        
        guard let guardianPos = escape["api_tow_idx"][0].int else { return }
        
        let fixedGuardianPos = guardianPos - 6 - 1
        
        guard case 0..<6 = fixedGuardianPos,
            let guardianId = fleetMembers(fleetId: 2)?[fixedGuardianPos] else {
                
                print("guardianPos is wrong")
                return
                
        }
        
        guard let escapeIdx = escape["api_escape_idx"][0].int,
            let damagedId = damagedShipId(damagedPos: escapeIdx) else {
                
                print("damagedPos is wrong")
                return
        }
        
        let store = TemporaryDataStore.oneTimeEditor()
        
        guard let guardian = store.createGuardEscaped() else {
            
            print("Can not create GuardEscaped for guardinan")
            return
        }
        
        guardian.shipID = guardianId
        guardian.ensured = false
        
        guard let damaged = store.createGuardEscaped() else {
            
            print("Can not create GuardEscaped for damaged")
            return
        }
        
        damaged.shipID = damagedId
        damaged.ensured = false
    }
    
    private func removeInvalidEntry() {
        
        let store = TemporaryDataStore.oneTimeEditor()
        
        store.notEnsuredGuardEscaped().forEach { store.delete($0) }
        store.save()
        Thread.sleep(forTimeInterval: 0.1)
        notify()
    }
    
    private func removeAllEntry() {
        
        let store = TemporaryDataStore.oneTimeEditor()
        
        store.guardEscaped().forEach { store.delete($0) }
        store.save()
        Thread.sleep(forTimeInterval: 0.1)
        notify()
    }
    
    func ensureGuardShelter() {
        
        let store = TemporaryDataStore.oneTimeEditor()
        
        store.guardEscaped().forEach { $0.ensured = true }
        store.save()
        Thread.sleep(forTimeInterval: 0.1)
        notify()
    }
    
    private func notify() {
        
        DispatchQueue.main.async {
            
            NotificationCenter.default.post(name: .DidUpdateGuardEscape, object: self)
        }
    }
}

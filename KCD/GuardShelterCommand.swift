//
//  GuardShelterCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/15.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

extension Notification.Name {
    
    static let DidUpdateGuardEscape = Notification.Name("com.masakih.KCD.Notification.DidUpdateGuardEscape")
}

final class GuardShelterCommand: JSONCommand {
        
    override class func canExecuteAPI(_ api: API) -> Bool {
        
        return api.type == .guardEscape
    }
    
    override func execute() {
        
        switch api.type {
            
        case .battleResult:
            reserveEscapeShips()
            
        case .map:
            removeInvalidEntry()
            
        case .guardEscape:
            ensureGuardShelter()
            
        case .port:
            removeAllEntry()
            
        default: return Logger.shared.log("Missing API: \(apiResponse.api)")
        }
    }
    
    private func damagedShipId(damagedPos: Int) -> Int? {
        
        let tempStore = TemporaryDataStore.default
        let firstDeckId = tempStore.sync { tempStore.battle()?.deckId ?? 1 }
        
        let store = ServerDataStore.default
        
        switch firstDeckId {
        case 1:
            switch damagedPos {
            case 1...6: return store.sync { store.deck(by: 1)?.shipId(of: damagedPos - 1) }
            case 7...12: return store.sync { store.deck(by: 2)?.shipId(of: damagedPos - 6 - 1) }
            default: return nil
            }
        case 3:
            return store.sync { store.deck(by: 3)?.shipId(of: damagedPos - 1) }
        default:
            return nil
        }
    }
    
    private func reserveEscapeShips() {
        
        let escape = data["api_escape"]
        
        guard let escapeIdx = escape["api_escape_idx"][0].int else { return }
        guard let damagedId = damagedShipId(damagedPos: escapeIdx) else {
            
            return  Logger.shared.log("damagedPos is wrong")
        }
        
        let store = TemporaryDataStore.oneTimeEditor()
        store.sync {
            
            guard let damaged = store.createGuardEscaped() else {
                
                return Logger.shared.log("Can not create GuardEscaped for damaged")
            }
            
            damaged.shipID = damagedId
            damaged.ensured = false
            
            // store guardian if needs
            guard let guardianPos = escape["api_tow_idx"][0].int else { return }
            
            let fixedGuardianPos = guardianPos - 6 - 1
            
            let sStore = ServerDataStore.default
            guard let guardianId = sStore.sync(execute: { sStore.deck(by: 2)?.shipId(of: fixedGuardianPos) }) else {
                
                return Logger.shared.log("guardianPos is wrong")
            }
            
            guard let guardian = store.createGuardEscaped() else {
                
                return Logger.shared.log("Can not create GuardEscaped for guardinan")
            }
            
            guardian.shipID = guardianId
            guardian.ensured = false
        }
    }
    
    private func removeInvalidEntry() {
        
        let store = TemporaryDataStore.oneTimeEditor()
        store.sync {
            store.notEnsuredGuardEscaped().forEach(store.delete)
            store.save(errorHandler: store.presentOnMainThread)
        }
        Thread.sleep(forTimeInterval: 0.1)
        notify()
    }
    
    private func removeAllEntry() {
        
        let store = TemporaryDataStore.oneTimeEditor()
        store.sync {
            store.guardEscaped().forEach(store.delete)
            store.save(errorHandler: store.presentOnMainThread)
        }
        Thread.sleep(forTimeInterval: 0.1)
        notify()
    }
    
    private func ensureGuardShelter() {
        
        let store = TemporaryDataStore.oneTimeEditor()
        store.sync {
            store.guardEscaped().forEach { $0.ensured = true }
            store.save(errorHandler: store.presentOnMainThread)
        }
        Thread.sleep(forTimeInterval: 0.1)
        notify()
    }
    
    private func notify() {
        
        DispatchQueue.main.async {
            
            NotificationCenter.default.post(name: .DidUpdateGuardEscape, object: self)
        }
    }
}

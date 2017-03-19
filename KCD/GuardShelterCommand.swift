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

class GuardShelterCommand: JSONCommand {
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
        guard let deck = ServerDataStore.default.deck(byId: fleetId)
            else { return nil }
        return [deck.ship_0, deck.ship_1, deck.ship_2,
                deck.ship_3, deck.ship_4, deck.ship_5]
    }
    private func damagedMemberPosition(escapeIdx: Any) -> Int? {
        switch escapeIdx {
        case let i as Int: return i
        case let a as [Int] where !a.isEmpty: return a[0]
        default: return nil
        }
    }
    private func damagedShipId(damagedPos: Int) -> Int? {
        if damagedPos > 6, 0..<6 ~= damagedPos - 6 - 1 {
            return fleetMembers(fleetId: 2)?[damagedPos - 6 - 1]
        }
        if 0..<6 ~= damagedPos - 1 {
            return fleetMembers(fleetId: 1)?[damagedPos - 1]
        }
        return nil
    }
    private func registerReserve() {
        let escape = data["api_escape"]
        let guardians = escape["api_tow_idx"]
        guard let guardianPos = guardians[0].int
            else { return }
        let fixedGuardianPos = guardianPos - 6 - 1
        guard 0..<6 ~= fixedGuardianPos,
            let guardianId = fleetMembers(fleetId: 2)?[fixedGuardianPos]
            else { return print("guardianPos is wrong") }
        
        guard let escapeIdx = escape["api_escape_idx"].int,
            let damagedPos = damagedMemberPosition(escapeIdx: escapeIdx),
            let damagedId = damagedShipId(damagedPos: damagedPos)
            else { return print("damagedPos is wrong") }
        
        let store = TemporaryDataStore.oneTimeEditor()
        guard let guardian = store.createGuardEscaped()
            else { return print("Can not create GuardEscaped for guardinan") }
        guardian.shipID = guardianId
        guardian.ensured = false
        
        guard let damaged = store.createGuardEscaped()
            else { return print("Can not create GuardEscaped for damaged") }
        damaged.shipID = damagedId
        damaged.ensured = false
    }
    private func removeInvalidEntry() {
        let store = TemporaryDataStore.oneTimeEditor()
        store.notEnsuredGuardEscaped().forEach { store.delete($0) }
        store.saveActionCore()
        Thread.sleep(forTimeInterval: 0.1)
        notify()
    }
    private func removeAllEntry() {
        let store = TemporaryDataStore.oneTimeEditor()
        store.guardEscaped().forEach { store.delete($0) }
        store.saveActionCore()
        Thread.sleep(forTimeInterval: 0.1)
        notify()
    }
    func ensureGuardShelter() {
        let store = TemporaryDataStore.oneTimeEditor()
        store.guardEscaped().forEach { $0.ensured = true }
        store.saveActionCore()
        Thread.sleep(forTimeInterval: 0.1)
        notify()
    }
    
    private func notify() {
        NotificationCenter.default.post(name: .DidUpdateGuardEscape, object: self)
    }
}

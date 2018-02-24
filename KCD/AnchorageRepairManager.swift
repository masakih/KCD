//
//  AnchorageRepairManager.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/22.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa


final class AnchorageRepairManager: NSObject {
    
    static let `default`: AnchorageRepairManager = AnchorageRepairManager()
    
    private let fleetManager = AppDelegate.shared.fleetManager
    private let repairShipTypeIds: [Int] = [19]
    
    override init() {
                
        super.init()
        
        let nc = NotificationCenter.default
        nc.addObserver(forName: .HenseiDidChange, object: nil, queue: nil) { notification in
            
            guard let userInfo = notification.userInfo else { return }
            guard let info = userInfo[ChangeHenseiCommand.userInfoKey] as? HenseiDidChangeUserInfo else { return }
            
            self.resetIfNeeds(info: info)
        }
        
        nc.addObserver(forName: .PortAPIReceived, object: nil, queue: nil) { _ in
            
            if Date().timeIntervalSince(self.repairTime) < 20 * 60 { return }
            
            self.reset()
        }
    }
    
    private(set) var repairTime: Date {
        
        get { return UserDefaults.standard[.repairTime] }
        set { UserDefaults.standard[.repairTime] = newValue }
    }
    
    private func reset() {
        
        repairTime = Date()
    }
    
    private func shipTypeId(fleetNumber: Int, position: Int) -> Int? {
        
        guard case 1...4 = fleetNumber else { return nil }
        guard case 0...5 = position else { return nil }
        
        let ship = fleetManager?.fleets[fleetNumber - 1][position]
        
        return ServerDataStore.default.sync { ship?.master_ship.stype.id }
    }
    
    private func shipTypeId(shipId: Int) -> Int? {
        
        let store = ServerDataStore.default
        return store.sync { store.ship(by: shipId)?.master_ship.stype.id }
    }
    
    private func needsReset(info: HenseiDidChangeUserInfo) -> Bool {
        
        // 変更のあった艦隊の旗艦は工作艦か？
        if let flagShipType = shipTypeId(fleetNumber: info.fleetNumber, position: 0),
            repairShipTypeIds.contains(flagShipType) {
            
            return true
        }
        if info.type == .replace,
            let replaceFleet = info.replaceFleetNumber,
            let flagShipType = shipTypeId(fleetNumber: replaceFleet, position: 0),
            repairShipTypeIds.contains(flagShipType) {
            
            return true
        }
        
        // 変更のあった艦娘は工作艦か？
        //     旗艦から外れたか？
        // 入れ替えた結果、工作艦が旗艦になったか？
        if info.type == .remove || info.type == .append || info.type == .replace,
            info.position == 0,
            let shipType = shipTypeId(shipId: info.shipID),
            repairShipTypeIds.contains(shipType) {
            
            return true
        }
        if info.type == .replace,
            let replacePos = info.replacePosition,
            replacePos == 0,
            let shipId = info.replaceShipID,
            let shipType = shipTypeId(shipId: shipId),
            repairShipTypeIds.contains(shipType) {
            
            return true
        }
        
        // 旗艦が外された結果、工作艦が旗艦になったか？
        if info.type == .remove,
            info.position == 0,
            let shipType = shipTypeId(fleetNumber: info.fleetNumber, position: 1),
            repairShipTypeIds.contains(shipType) {
            
            return true
        }
        
        return false
    }
    private func resetIfNeeds(info: HenseiDidChangeUserInfo) {
        
        if needsReset(info: info) { reset() }
    }
}

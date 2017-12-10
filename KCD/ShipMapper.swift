//
//  ShipMapper.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/02/23.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa
import SwiftyJSON

final class ShipMapper: JSONMapper {
    
    private static let ignoreKeys = ["api_gomes", "api_gomes2", "api_broken", "api_powup",
                                     "api_voicef", "api_afterlv", "api_aftershipid", "api_backs",
                                     "api_slotnum", "api_stype", "api_name", "api_yomi",
                                     "api_raig", "api_luck", "api_saku", "api_raim", "api_baku",
                                     "api_taik", "api_houg", "api_houm", "api_tyku",
                                     "api_ndock_item", "api_star",
                                     "api_ndock_time_str", "api_member_id",
                                     "api_fuel_max", "api_bull_max"]
    
    let apiResponse: APIResponse
    let configuration: MappingConfiguration<Ship>
    
    required init(_ apiResponse: APIResponse) {
        
        self.apiResponse = apiResponse
        self.configuration = MappingConfiguration(entity: Ship.entity,
                                                  dataKeys: ShipMapper.dataKeys(apiResponse),
                                                  editorStore: ServerDataStore.oneTimeEditor(),
                                                  ignoreKeys: ShipMapper.ignoreKeys)
    }
    
    // slotDepriveの時に２種類のデータが来るため
    init(forSlotDepriveUnset apiResponse: APIResponse) {
        
        self.apiResponse = apiResponse
        self.configuration = MappingConfiguration(entity: Ship.entity,
                                                  dataKeys: ["api_data", "api_ship_data", "api_unset_ship"],
                                                  editorStore: ServerDataStore.oneTimeEditor(),
                                                  ignoreKeys: ShipMapper.ignoreKeys)
    }
    
    private class func dataKeys(_ apiResponse: APIResponse) -> [String] {
        
        switch apiResponse.api.endpoint {
            
        case .port, .getShip, .powerup: return ["api_data", "api_ship"]
            
        case .ship3, .shipDeck: return ["api_data", "api_ship_data"]
            
        case .slotDeprive: return ["api_data", "api_ship_data", "api_set_ship"]
            
        case .ship: return ["api_data"]
            
        default: return Logger.shared.log("Missing API: \(apiResponse.api)", value: ["api_data"])
        }
    }
    
    private var registerIds: [Int] = []
    private lazy var masterShips: [MasterShip] = {
        
        return ServerDataStore.default.sortedMasterShipsById()
    }()
    private lazy var slotItems: [SlotItem] = {
        
        return ServerDataStore.default.sortedSlotItemsById()
    }()
    private var needsDeleteUnregisteredShip: Bool {
        
        switch apiResponse.api.endpoint {
        case .ship3, .getShip, .shipDeck,
             .powerup, .slotDeprive:
            return false
            
        default:
            return true
        }
    }
    
    private var store: ServerDataStore? {
        
        return configuration.editorStore as? ServerDataStore
    }
    
    func beginRegister(_ ship: Ship) {
        
        ship.sally_area = nil
    }
    
    func handleExtraValue(_ value: JSON, forKey key: String, to ship: Ship) -> Bool {
        
        // 取得後破棄した装備のデータを削除するため保有IDを保存
        if key == "api_id" {
            
            guard let id = value.int else { return false }
            
            registerIds.append(id)
            
            return false
        }
        
        if key == "api_ship_id" {
            
            guard let masterId = value.int else { return false }
            
            setMaster(masterId, to: ship)
            
            return true
        }
        
        if key == "api_exp" {
            
            guard let exp = value[0].int else { return false }
            
            ship.exp = exp
            
            return true
        }
        
        if key == "api_slot" {
            
            setSlot(value, to: ship)
            
            return false
        }
        
        if key == "api_slot_ex" {
            
            guard let ex = value.int else { return false }
            
            setExtraSlot(ex, to: ship)
            
            return false
        }
        
        return false
    }
    
    func finishOperating() {
        
        if !needsDeleteUnregisteredShip { return }
        
        store?.ships(exclude: registerIds).forEach { store?.delete($0) }
    }
    
    private func setMaster(_ masterId: Int, to ship: Ship) {
        
        if ship.ship_id == masterId { return }
        
        guard let mShip = masterShips.binarySearch(comparator: { $0.id ==? masterId }),
            let masterShip = store?.object(of: MasterShip.entity, with: mShip.objectID) else {
                
                return Logger.shared.log("Can not convert to current moc object masterShip")
        }
        
        ship.master_ship = masterShip
        ship.ship_id = masterId
    }
    
    private func setSlot(_ slotItems: JSON, to ship: Ship) {
        
        guard let converSlotItems = slotItems.arrayObject as? [Int] else { return }
        guard let store = store else { return }
        
        let newItems: [SlotItem] =
            converSlotItems.flatMap { item in
                
                if item == 0 || item == -1 { return nil }
                
                guard let found = self.slotItems.binarySearch(comparator: { $0.id ==? item }),
                    let slotItem = store.object(of: SlotItem.entity, with: found.objectID) else {
                        
                        let maxV = converSlotItems.last
                        if maxV != nil, maxV! < item {
                            
                            Debug.print("item is maybe unregistered, so it is new ship's equipment.")
                            return nil
                        }
                        Logger.shared.log("Can not convert to current moc object slotItem")
                        return nil
                }
                
                return slotItem
        }
        
        ship.equippedItem = NSOrderedSet(array: newItems)
    }
    
    private func setExtraSlot(_ exSlotItem: Int, to ship: Ship) {
        
        guard exSlotItem != -1, exSlotItem != 0 else { return }
        guard let found = slotItems.binarySearch(comparator: { $0.id ==? exSlotItem }),
            let ex = store?.object(of: SlotItem.entity, with: found.objectID) else {
                
                return Logger.shared.log("Can not convert to current moc object")
        }
        
        ship.extraItem = ex
    }
}

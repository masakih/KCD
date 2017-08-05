//
//  ShipMapper.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/02/23.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa
import SwiftyJSON

extension MappingConfiguration {
    
    func change(dataKeys: [String]) -> MappingConfiguration {
        
        return MappingConfiguration(entity: self.entity,
                                    dataKeys: dataKeys,
                                    primaryKeys: self.primaryKeys,
                                    editorStore: self.editorStore,
                                    ignoreKeys: self.ignoreKeys)
    }
}

final class ShipMapper: JSONMapper {
    
    typealias ObjectType = Ship
    let apiResponse: APIResponse
    let configuration: MappingConfiguration<Ship>
    
    required init(_ apiResponse: APIResponse) {
        
        self.apiResponse = apiResponse
        self.configuration = MappingConfiguration(entity: Ship.entity,
                                                  dataKeys: ShipMapper.dataKeys(apiResponse),
                                                  editorStore: ServerDataStore.oneTimeEditor(),
                                                  ignoreKeys:
            ["api_gomes", "api_gomes2", "api_broken", "api_powup",
             "api_voicef", "api_afterlv", "api_aftershipid", "api_backs",
             "api_slotnum", "api_stype", "api_name", "api_yomi",
             "api_raig", "api_luck", "api_saku", "api_raim", "api_baku",
             "api_taik", "api_houg", "api_houm", "api_tyku",
             "api_ndock_item", "api_star",
             "api_ndock_time_str", "api_member_id",
             "api_fuel_max", "api_bull_max"])
        
        // kaisouSlotDepriveでは同時に２種類のデータが入る
        if let api = ShipAPI(rawValue: apiResponse.api),
            api == .kaisouSlotDeprive {
            
            let conf = self.configuration.change(dataKeys: ["api_data", "api_ship_data", "api_unset_ship"])
            ShipMapper(apiResponse, configuration: conf).commit()
        }
    }
    
    private init(_ apiResponse: APIResponse, configuration: MappingConfiguration<Ship>) {
        
        self.apiResponse = apiResponse
        self.configuration = configuration
    }
    
    
    private enum ShipAPI: String {
        
        case getMemberShip = "/kcsapi/api_get_member/ship"
        case port = "/kcsapi/api_port/port"
        case getMemberShip3 = "/kcsapi/api_get_member/ship3"
        case kousyouGetShip = "/kcsapi/api_req_kousyou/getship"
        case getMemberShipDeck = "/kcsapi/api_get_member/ship_deck"
        case kaisouPowerUp = "/kcsapi/api_req_kaisou/powerup"
        case kaisouSlotDeprive = "/kcsapi/api_req_kaisou/slot_deprive"
    }
    
    private class func dataKeys(_ apiResponse: APIResponse) -> [String] {
        
        guard let shipApi = ShipAPI(rawValue: apiResponse.api)
            else { return ["api_data"] }
        
        switch shipApi {
        case .port: return ["api_data", "api_ship"]
            
        case .getMemberShip3: return ["api_data", "api_ship_data"]
            
        case .kousyouGetShip: return ["api_data", "api_ship"]
            
        case .getMemberShipDeck: return ["api_data", "api_ship_data"]
            
        case .kaisouPowerUp: return ["api_data", "api_ship"]
            
        case .kaisouSlotDeprive: return ["api_data", "api_ship_data", "api_set_ship"]
            
        case .getMemberShip: return ["api_data"]
        }
    }
    
    private var registerIds: [Int] = []
    private lazy var masterShips: [MasterShip] = {
        
        return ServerDataStore.default.sortedMasterShipsById()
    }()
    private lazy var slotItems: [SlotItem] = {
        
        return ServerDataStore.default.sortedSlotItemsById()
    }()
    private var isDeleteNotExist: Bool {
        
        guard let shipApi = ShipAPI(rawValue: apiResponse.api)
            else { return true }
        
        switch shipApi {
        case .getMemberShip3, .kousyouGetShip, .getMemberShipDeck,
             .kaisouPowerUp, .kaisouSlotDeprive:
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
            
            guard let id = value.int
                else { return false }
            
            registerIds.append(id)
            
            return false
        }
        
        if key == "api_ship_id" {
            
            guard let masterId = value.int
                else { return false }
            
            setMaster(masterId, to: ship)
            
            return true
        }
        
        if key == "api_exp" {
            
            guard let exp = value[0].int
                else { return false }
            
            ship.exp = exp
            
            return true
        }
        
        if key == "api_slot" {
            
            setSlot(value, to: ship)
            
            return false
        }
        
        if key == "api_slot_ex" {
            
            guard let ex = value.int
                else { return false }
            
            setExtraSlot(ex, to: ship)
            
            return false
        }
        
        return false
    }
    
    func finishOperating() {
        
        if !isDeleteNotExist { return }
        
        store?.ships(exclude: registerIds).forEach { store?.delete($0) }
    }
    
    private func setMaster(_ masterId: Int, to ship: Ship) {
        
        if ship.ship_id == masterId { return }
        
        guard let mShip = masterShips.binarySearch(comparator: { $0.id ==? masterId }),
            let masterShip = store?.object(with: mShip.objectID) as? MasterShip
            else { return print("Can not convert to current moc object masterShip") }
        
        ship.master_ship = masterShip
        ship.ship_id = masterId
    }
    
    private func setSlot(_ slotItems: JSON, to ship: Ship) {
        
        guard let converSlotItems = slotItems.arrayObject as? [Int],
            let store = store
            else { return }
        
        let newItems: [SlotItem] =
            converSlotItems.flatMap { item in
                
                if item == 0 || item == -1 { return nil }
                
                guard let found = self.slotItems.binarySearch(comparator: { $0.id ==? item }),
                    let slotItem = store.object(with: found.objectID) as? SlotItem
                    else {
                        
                        let maxV = converSlotItems.last
                        if maxV != nil, maxV! < item {
                            
                            #if DEBUG
                                print("item is maybe unregistered, so it is new ship's equipment.")
                            #endif
                            return nil
                        }
                        print("Can not convert to current moc object slotItem")
                        return nil
                }
                
                return slotItem
        }
        
        ship.equippedItem = NSOrderedSet(array: newItems)
    }
    
    private func setExtraSlot(_ exSlotItem: Int, to ship: Ship) {
        
        guard exSlotItem != -1,
            exSlotItem != 0
            else { return }
        
        guard let found = slotItems.binarySearch(comparator: { $0.id ==? exSlotItem }),
            let ex = store?.object(with: found.objectID) as? SlotItem
            else { return print("Can not convert to current moc object") }
        
        ship.extraItem = ex
    }
}

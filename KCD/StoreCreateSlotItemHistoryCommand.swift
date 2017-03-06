//
//  StoreCreateSlotItemHistoryCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/11.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

class StoreCreateSlotItemHistoryCommand: JSONCommand {
    override func execute() {
        guard let fuel = arguments["api_item1"].flatMap({ Int($0) }),
            let bull = arguments["api_item2"].flatMap({ Int($0) }),
            let steel = arguments["api_item3"].flatMap({ Int($0) }),
            let bauxite = arguments["api_item4"].flatMap({ Int($0) })
            else { return print("Parameter is Wrong") }
        
        guard let data = json[dataKey] as? [String: Any],
            let success = data["api_create_flag"] as? Bool
            else { return print("api_create_flag is wrong") }
        let name = masterSlotItemName(sccess: success, data: data)
        let numberOfUsedKaihatuSizai = success ? 1 : 0
        
        let store = ServerDataStore.default
        guard let ship0 = store.deck(byId: 1)?.ship_0,
            let flagShip = store.ship(byId: ship0)
            else { return print("Flagship is not found") }
        
        guard let basic = ServerDataStore.default.basic()
            else { return print("Basic is wrong") }
        
        let localStore = LocalDataStore.oneTimeEditor()
        guard let newHistory = localStore.createKaihatuHistory()
            else { return print("Can not create new KaihatuHistory entry") }
        newHistory.name = name
        newHistory.fuel = fuel
        newHistory.bull = bull
        newHistory.steel = steel
        newHistory.bauxite = bauxite
        newHistory.kaihatusizai = numberOfUsedKaihatuSizai
        newHistory.flagShipLv = flagShip.lv
        newHistory.flagShipName = flagShip.name
        newHistory.commanderLv = basic.level
        newHistory.date = Date()
    }
    
    private func masterSlotItemName(sccess: Bool, data: [String: Any]) -> String {
        if !sccess {
            return NSLocalizedString("fail to develop", comment: "fail to develop")
        }
        guard let si = data["api_slot_item"] as? [String: Any],
            let slotItemId = si["api_slotitem_id"] as? Int
            else {
                print("api_slotitem_id is wrong")
                return ""
        }
        
        return ServerDataStore.default.masterSlotItem(by: slotItemId)?.name ?? ""
    }
}

//
//  StoreCreateSlotItemHistoryCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/11.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa
import SwiftyJSON

class StoreCreateSlotItemHistoryCommand: JSONCommand {
    override func execute() {
        guard let fuel = parameter["api_item1"].int,
            let bull = parameter["api_item2"].int,
            let steel = parameter["api_item3"].int,
            let bauxite = parameter["api_item4"].int
            else { return print("Parameter is Wrong") }
        
        guard let success = data["api_create_flag"].bool
            else { return print("api_create_flag is wrong") }
        let name = masterSlotItemName(sccess: success, data: data)
        let numberOfUsedKaihatuSizai = success ? 1 : 0
        
        let store = ServerDataStore.default
        guard let ship0 = store.deck(byId: 1)?.ship_0,
            let flagShip = store.ship(byId: ship0)
            else { return print("Flagship is not found") }
        
        guard let basic = store.basic()
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
    
    private func masterSlotItemName(sccess: Bool, data: JSON) -> String {
        if !sccess {
            return NSLocalizedString("fail to develop", comment: "fail to develop")
        }
        guard let slotItemId = data["api_slot_item"]["api_slotitem_id"].int
            else {
                print("api_slotitem_id is wrong")
                return ""
        }
        
        return ServerDataStore.default.masterSlotItem(by: slotItemId)?.name ?? ""
    }
}

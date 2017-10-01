//
//  StoreCreateSlotItemHistoryCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/11.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa
import SwiftyJSON

final class StoreCreateSlotItemHistoryCommand: JSONCommand {
    
    override func execute() {
        
        guard let fuel = parameter["api_item1"].int,
            let bull = parameter["api_item2"].int,
            let steel = parameter["api_item3"].int,
            let bauxite = parameter["api_item4"].int else {
                
                print("Parameter is Wrong")
                return
        }
        
        let success = data["api_create_flag"].int ?? 0
        let name = masterSlotItemName(sccess: success, data: data)
        let numberOfUsedKaihatuSizai = success != 0 ? 1 : 0
        
        let store = ServerDataStore.default
        
        guard let flagShip = store.deck(by: 1).map({ $0.ship_0 }).flatMap({ store.ship(by: $0) }) else {
            
            print("Flagship is not found")
            return
        }
        
        guard let basic = store.basic() else { return print("Basic is wrong") }
        
        let localStore = LocalDataStore.oneTimeEditor()
        
        guard let newHistory = localStore.createKaihatuHistory() else {
            
            print("Can not create new KaihatuHistory entry")
            return
        }
        
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
    
    private func masterSlotItemName(sccess: Int, data: JSON) -> String {
        
        if sccess == 0 {
            
            return LocalizedStrings.failDevelop.string
            
        }
        
        guard let slotItemId = data["api_slot_item"]["api_slotitem_id"].int else {
            
            print("api_slotitem_id is wrong")
            return ""
        }
        
        return ServerDataStore.default.masterSlotItem(by: slotItemId)?.name ?? ""
    }
}

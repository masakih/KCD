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
                
                Logger.shared.log("Parameter is Wrong")
                
                return
        }
        
        let success = data["api_create_flag"].int ?? 0
        let name = masterSlotItemName(sccess: success, data: data)
        let numberOfUsedKaihatuSizai = (success != 0 ? 1 : 0)
        
        let store = ServerDataStore.default
        guard let flagShip = store.sync(execute: { store.deck(by: 1)?[0] }) else {
            
            Logger.shared.log("Flagship is not found")
            
            return
        }
        
        guard let commanderLv = store.sync(execute: { store.basic()?.level }) else {
            
            Logger.shared.log("Basic is wrong")
            
            return
        }
        
        let localStore = LocalDataStore.oneTimeEditor()
        guard let newHistory = localStore.sync(execute: { localStore.createKaihatuHistory() }) else {
            
            Logger.shared.log("Can not create new KaihatuHistory entry")
            
            return
        }
        
        localStore.sync {
            
            newHistory.name = name
            newHistory.fuel = fuel
            newHistory.bull = bull
            newHistory.steel = steel
            newHistory.bauxite = bauxite
            newHistory.kaihatusizai = numberOfUsedKaihatuSizai
            newHistory.flagShipLv = store.sync { flagShip.lv }
            newHistory.flagShipName = store.sync { flagShip.name }
            newHistory.commanderLv = commanderLv
            newHistory.date = Date()
        }
    }
    
    private func masterSlotItemName(sccess: Int, data: JSON) -> String {
        
        if sccess == 0 {
            
            return LocalizedStrings.failDevelop.string
        }
        
        guard let slotItemId = data["api_slot_item"]["api_slotitem_id"].int else {
            
            Logger.shared.log("api_slotitem_id is wrong")
            
            return ""
        }
        
        let store = ServerDataStore.default
        
        return store.sync { store.masterSlotItem(by: slotItemId)?.name ?? "" }
    }
}
